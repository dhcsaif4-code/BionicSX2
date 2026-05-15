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

    # CMake 4.x requires cmake_minimum_required in all CMakeLists.txt.
    # Vendored libraries may not have it. Add it if missing.
    if [ -f "$SRC/CMakeLists.txt" ]; then
        if ! grep -q "cmake_minimum_required" "$SRC/CMakeLists.txt" 2>/dev/null; then
            echo "  Patching $SRC/CMakeLists.txt: adding cmake_minimum_required"
            sed -i '' '1s/^/cmake_minimum_required(VERSION 3.20)\nproject('"$NAME"')\n/' "$SRC/CMakeLists.txt"
        fi
        if ! grep -q "^project(" "$SRC/CMakeLists.txt" 2>/dev/null; then
            echo "  Patching $SRC/CMakeLists.txt: adding project()"
            sed -i '' '1s/^/project('"$NAME"')\n/' "$SRC/CMakeLists.txt"
        fi
    fi

    cmake -S "$SRC" -B "$BUILD_DIR/$NAME" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        -DCMAKE_FIND_ROOT_PATH="$INSTALL_DIR" \
        -DCMAKE_PREFIX_PATH="$INSTALL_DIR" \
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

# lzma/xz (pcsx2/3rdparty/lzma — builds as pcsx2-lzma)
if [ -d "$REPO_ROOT/pcsx2/3rdparty/lzma" ]; then
    build_lib "lzma" "$REPO_ROOT/pcsx2/3rdparty/lzma"
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
# NOTE: pcsx2/3rdparty/libzip hardcodes HAVE_LIBZSTD=TRUE and links Zstd::Zstd
# without calling find_package(Zstd). We must patch this at build time since
# pcsx2 is a submodule. Upstream libzip handles this correctly via Findzstd.cmake.
LIBZIP_SRC="$REPO_ROOT/pcsx2/3rdparty/libzip"
if [ ! -d "$LIBZIP_SRC" ]; then
    ensure_src "libzip" "https://github.com/nih-at/libzip.git" "v1.11.2" >/dev/null
    LIBZIP_SRC="$SRC_DIR/libzip"
fi
# Patch vendored libzip to remove hardcoded targets not provided standalone
# (pcsx2's CMake infrastructure provides Zstd::Zstd/ZLIB::ZLIB, but not when
#  building libzip standalone for iOS cross-compilation)
if grep -q "target_link_libraries.*Zstd::Zstd" "$LIBZIP_SRC/CMakeLists.txt" 2>/dev/null; then
    echo "  Patching libzip CMakeLists.txt to remove hardcoded targets (bringup phase)"
    sed -i '' 's/set(HAVE_LIBZSTD TRUE)/set(HAVE_LIBZSTD FALSE)/' "$LIBZIP_SRC/CMakeLists.txt"
    sed -i '' '/target_link_libraries(zip PRIVATE Zstd::Zstd)/d' "$LIBZIP_SRC/CMakeLists.txt"
    sed -i '' '/target_sources(zip PRIVATE lib\/zip_algorithm_zstd.c)/d' "$LIBZIP_SRC/CMakeLists.txt"
    # Remove ZLIB::ZLIB target_link — zlib functional but target not exposed standalone
    sed -i '' '/target_link_libraries(zip PRIVATE ZLIB::ZLIB)/d' "$LIBZIP_SRC/CMakeLists.txt"
    sed -i '' '/target_link_libraries(zip PUBLIC ZLIB::ZLIB)/d' "$LIBZIP_SRC/CMakeLists.txt"
fi
build_lib "libzip" "$LIBZIP_SRC" \
    -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_SHARED_LIBS=OFF

# freetype (depends on zlib + libpng)
ensure_src "freetype" "https://github.com/freetype/freetype.git" "VER-2-13-3" >/dev/null
build_lib "freetype" "$SRC_DIR/freetype" \
    -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_HARFBUZZ=ON \
    -DFT_DISABLE_BROTLI=ON -DZLIB_ROOT="$INSTALL_DIR" \
    -DPNG_ROOT="$INSTALL_DIR"

# ============================================================
# TIER 4 — Depends on lz4 + zstd + zlib
# ============================================================

# libchdr — skipped for bringup (vendored version has no cmake_minimum_required,
# designed for add_subdirectory use. Revisit when upstream repo is available.)
echo ">>> libchdr SKIPPED (bringup phase — no cmake_minimum_required in vendored CMakeLists.txt)"
echo ">>> libchdr will be built via add_subdirectory in main CMakeLists.txt when ready"

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

# cubeb — SKIPPED for bringup. The vendored cubeb_audiounit.cpp is macOS-only
# with insufficient #if TARGET_OS_IPHONE guards (AudioDeviceID, etc.).
# BionicSX2 uses native AudioStream_iOS.mm with AVAudioEngine/AudioUnit directly.
echo ">>> cubeb SKIPPED (bringup phase — macOS-only audiounit backend)"
echo ">>> Using native iOS audio implementation in AudioStream_iOS.mm"

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
