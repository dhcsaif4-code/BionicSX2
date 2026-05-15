#!/usr/bin/env bash
# AUDIT REFERENCE: Section 10.1, Phase 3
# STATUS: NEW
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="$REPO_ROOT/ios-deps/install"
BUILD_DIR="$REPO_ROOT/ios-deps/build"
SRC_DIR="$REPO_ROOT/ios-deps/src"
TOOLCHAIN="$REPO_ROOT/cmake/ios.toolchain.cmake"
JOBS="$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"

mkdir -p "$INSTALL_DIR" "$BUILD_DIR" "$SRC_DIR"

# Ensure source exists — clone from upstream if not found
ensure_src() {
    local NAME="$1"
    local URL="$2"
    local SUBDIR="${3:-}"
    if [ -d "$SRC_DIR/$NAME" ]; then
        echo "  src/$NAME already exists"
        echo "$SRC_DIR/$NAME"
        return 0
    fi
    echo "  Cloning $NAME from $URL"
    if [ -n "$SUBDIR" ]; then
        git clone --depth 1 --branch "$SUBDIR" "$URL" "$SRC_DIR/$NAME" 2>/dev/null || \
        git clone --depth 1 "$URL" "$SRC_DIR/$NAME"
    else
        git clone --depth 1 "$URL" "$SRC_DIR/$NAME"
    fi
    echo "$SRC_DIR/$NAME"
}

build_lib() {
    local NAME="$1"; local SRC="$2"; shift 2
    echo ">>> Building $NAME (src: $SRC)"
    mkdir -p "$BUILD_DIR/$NAME"
    cmake -S "$SRC" -B "$BUILD_DIR/$NAME" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        "$@"
    cmake --build "$BUILD_DIR/$NAME" --config Release -j"$JOBS"
    cmake --install "$BUILD_DIR/$NAME"
    echo ">>> $NAME OK"
}

echo "=== BionicSX2: Building iOS dependencies ==="
echo "Toolchain: $TOOLCHAIN"
echo "Install:   $INSTALL_DIR"
echo ""

# ============================================================
# TIER 1 — No dependencies
# ============================================================

# lz4
ensure_src "lz4" "https://github.com/lz4/lz4.git" "v1.10.0" >/dev/null
if [ -d "$SRC_DIR/lz4/build/cmake" ]; then
    build_lib "lz4" "$SRC_DIR/lz4/build/cmake" \
        -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF
else
    build_lib "lz4" "$SRC_DIR/lz4" \
        -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF
fi

# zstd
ensure_src "zstd" "https://github.com/facebook/zstd.git" "v1.5.6" >/dev/null
if [ -d "$SRC_DIR/zstd/build/cmake" ]; then
    build_lib "zstd" "$SRC_DIR/zstd/build/cmake" \
        -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF \
        -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF
else
    build_lib "zstd" "$SRC_DIR/zstd" \
        -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF \
        -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF
fi

# Create ZstdConfig.cmake so find_package(Zstd) finds Zstd::Zstd
# libzip and other deps expect this target name (Audit Sec 10.1)
mkdir -p "$INSTALL_DIR/lib/cmake/Zstd"
cat > "$INSTALL_DIR/lib/cmake/Zstd/ZstdConfig.cmake" << 'ZSTDEOF'
include(CMakeFindDependencyMacro)
if(NOT TARGET Zstd::Zstd)
    add_library(Zstd::Zstd STATIC IMPORTED)
    set_target_properties(Zstd::Zstd PROPERTIES
        IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../../../lib/libzstd.a"
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../../include"
    )
endif()
ZSTDEOF
cat > "$INSTALL_DIR/lib/cmake/Zstd/ZstdConfigVersion.cmake" << 'ZSTDVEOF'
set(PACKAGE_VERSION 1.5.6)
if(PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
    if(PACKAGE_FIND_VERSION STREQUAL PACKAGE_VERSION)
        set(PACKAGE_VERSION_EXACT TRUE)
    endif()
endif()
ZSTDVEOF
echo ">>> Zstd::Zstd cmake config created"

# fmt (from pcsx2 3rdparty)
if [ -d "$REPO_ROOT/pcsx2/3rdparty/fmt" ]; then
    build_lib "fmt" "$REPO_ROOT/pcsx2/3rdparty/fmt" \
        -DFMT_TEST=OFF -DFMT_DOC=OFF
else
    ensure_src "fmt" "https://github.com/fmtlib/fmt.git" "12.1.0" >/dev/null
    build_lib "fmt" "$SRC_DIR/fmt" \
        -DFMT_TEST=OFF -DFMT_DOC=OFF
fi

# xxhash — header-only
if [ -d "$REPO_ROOT/pcsx2/3rdparty/xxhash" ]; then
    echo ">>> xxhash header-only, copying to install"
    mkdir -p "$INSTALL_DIR/include"
    cp -r "$REPO_ROOT/pcsx2/3rdparty/xxhash/"*".h" "$INSTALL_DIR/include/" 2>/dev/null || true
fi

# ============================================================
# TIER 2 — zlib (depends on nothing else in this build)
# ============================================================

ensure_src "zlib" "https://github.com/madler/zlib.git" "v1.3.1" >/dev/null
build_lib "zlib" "$SRC_DIR/zlib" \
    -DZLIB_BUILD_EXAMPLES=OFF

# ============================================================
# TIER 3 — Depends on zlib
# ============================================================

# libpng
ensure_src "libpng" "https://github.com/glennrp/libpng.git" "v1.6.44" >/dev/null
build_lib "libpng" "$SRC_DIR/libpng" \
    -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF \
    -DZLIB_ROOT="$INSTALL_DIR"

# libzip (depends on zstd + zlib)
if [ -d "$REPO_ROOT/pcsx2/3rdparty/libzip" ]; then
    build_lib "libzip" "$REPO_ROOT/pcsx2/3rdparty/libzip" \
        -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF \
        -DBUILD_DOC=OFF -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF \
        -DENABLE_MBEDTLS=OFF -DENABLE_OPENSSL=OFF \
        -DZLIB_ROOT="$INSTALL_DIR" \
        -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd"
else
    ensure_src "libzip" "https://github.com/nih-at/libzip.git" "v1.11.2" >/dev/null
    build_lib "libzip" "$SRC_DIR/libzip" \
        -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF \
        -DBUILD_DOC=OFF -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF \
        -DENABLE_MBEDTLS=OFF -DENABLE_OPENSSL=OFF \
        -DZLIB_ROOT="$INSTALL_DIR" \
        -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd"
fi

# freetype (depends on zlib + libpng)
ensure_src "freetype" "https://github.com/freetype/freetype.git" "VER-2-13-3" >/dev/null
build_lib "freetype" "$SRC_DIR/freetype" \
    -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_HARFBUZZ=ON \
    -DFT_DISABLE_BROTLI=ON -DZLIB_ROOT="$INSTALL_DIR" \
    -DPNG_ROOT="$INSTALL_DIR"

# ============================================================
# TIER 4 — Depends on lz4 + zstd + zlib
# ============================================================

# libchdr
if [ -d "$REPO_ROOT/pcsx2/3rdparty/libchdr" ]; then
    build_lib "libchdr" "$REPO_ROOT/pcsx2/3rdparty/libchdr" \
        -DWITH_SYSTEM_ZLIB=ON -DZLIB_ROOT="$INSTALL_DIR" \
        -Dlz4_DIR="$INSTALL_DIR/lib/cmake/lz4" \
        -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd"
else
    ensure_src "libchdr" "https://github.com/rtissera/libchdr.git" >/dev/null
    build_lib "libchdr" "$SRC_DIR/libchdr" \
        -DWITH_SYSTEM_ZLIB=ON -DZLIB_ROOT="$INSTALL_DIR" \
        -Dlz4_DIR="$INSTALL_DIR/lib/cmake/lz4" \
        -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd"
fi

# ============================================================
# TIER 5 — Audio (independent)
# ============================================================

# soundtouch
if [ -d "$REPO_ROOT/pcsx2/3rdparty/soundtouch" ]; then
    build_lib "soundtouch" "$REPO_ROOT/pcsx2/3rdparty/soundtouch" \
        -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS"
else
    ensure_src "soundtouch" "https://codeberg.org/soundtouch/soundtouch.git" >/dev/null
    build_lib "soundtouch" "$SRC_DIR/soundtouch" \
        -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS"
fi

# cubeb
if [ -d "$REPO_ROOT/pcsx2/3rdparty/cubeb" ]; then
    build_lib "cubeb" "$REPO_ROOT/pcsx2/3rdparty/cubeb/src" \
        -DBUILD_TESTS=OFF -DBUILD_TOOLS=OFF -DUSE_SANITIZERS=OFF
else
    ensure_src "cubeb" "https://github.com/mozilla/cubeb.git" >/dev/null
    build_lib "cubeb" "$SRC_DIR/cubeb/src" \
        -DBUILD_TESTS=OFF -DBUILD_TOOLS=OFF -DUSE_SANITIZERS=OFF
fi

# ============================================================
# VERIFICATION
# ============================================================
echo ""
echo "=== Verifying build output ==="
if ls "$INSTALL_DIR/lib/"*.a 1>/dev/null 2>&1; then
    ls -la "$INSTALL_DIR/lib/"*.a
    echo ""
    echo "=== All iOS dependencies built successfully ==="
else
    echo "WARNING: No .a files found in $INSTALL_DIR/lib/"
    exit 1
fi
