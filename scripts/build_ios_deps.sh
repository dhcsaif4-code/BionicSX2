#!/usr/bin/env bash
# AUDIT REFERENCE: Section 10.1, Phase 3
# STATUS: NEW
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="$REPO_ROOT/ios-deps/install"
BUILD_DIR="$REPO_ROOT/ios-deps/build"
SRC_DIR="$REPO_ROOT/ios-deps/src"
TOOLCHAIN="$REPO_ROOT/cmake/ios.toolchain.cmake"

mkdir -p "$INSTALL_DIR" "$BUILD_DIR" "$SRC_DIR"

build_lib() {
    local NAME="$1"; local SRC="$2"; shift 2
    echo ">>> Building $NAME"
    mkdir -p "$BUILD_DIR/$NAME"
    cmake -S "$SRC" -B "$BUILD_DIR/$NAME" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        "$@"
    cmake --build "$BUILD_DIR/$NAME" --config Release -j"$(sysctl -n hw.logicalcpu)"
    cmake --install "$BUILD_DIR/$NAME"
    echo ">>> $NAME OK"
}

echo "=== BionicSX2: Building iOS dependencies ==="

# TIER 1 — No dependencies
# lz4
if [ -d "$REPO_ROOT/pcsx2/3rdparty/lz4" ]; then
    build_lib "lz4" "$REPO_ROOT/pcsx2/3rdparty/lz4/build/cmake" \
        -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF
else
    echo "WARNING: lz4 source not found in 3rdparty"
fi

# zstd
if [ -d "$REPO_ROOT/pcsx2/3rdparty/zstd" ]; then
    build_lib "zstd" "$REPO_ROOT/pcsx2/3rdparty/zstd/build/cmake" \
        -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF \
        -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF
else
    echo "WARNING: zstd source not found in 3rdparty"
fi

# fmt
if [ -d "$REPO_ROOT/pcsx2/3rdparty/fmt" ]; then
    build_lib "fmt" "$REPO_ROOT/pcsx2/3rdparty/fmt" \
        -DFMT_TEST=OFF -DFMT_DOC=OFF
else
    echo "WARNING: fmt source not found in 3rdparty"
fi

# TIER 2 — Depends on lz4/zstd
# zlib
if [ -d "$REPO_ROOT/pcsx2/3rdparty/zlib" ]; then
    build_lib "zlib" "$REPO_ROOT/pcsx2/3rdparty/zlib" \
        -DZLIB_BUILD_EXAMPLES=OFF
else
    echo "WARNING: zlib source not found in 3rdparty"
fi

# TIER 3 — Depends on zlib
# libpng
if [ -d "$REPO_ROOT/pcsx2/3rdparty/libpng" ]; then
    build_lib "libpng" "$REPO_ROOT/pcsx2/3rdparty/libpng" \
        -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF \
        -DZLIB_ROOT="$INSTALL_DIR"
else
    echo "WARNING: libpng source not found in 3rdparty"
fi

# libzip
if [ -d "$REPO_ROOT/pcsx2/3rdparty/libzip" ]; then
    build_lib "libzip" "$REPO_ROOT/pcsx2/3rdparty/libzip" \
        -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF \
        -DBUILD_DOC=OFF -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF \
        -DENABLE_MBEDTLS=OFF -DENABLE_OPENSSL=OFF \
        -DZLIB_ROOT="$INSTALL_DIR"
else
    echo "WARNING: libzip source not found in 3rdparty"
fi

# TIER 5 — Audio (independent)
# soundtouch
if [ -d "$REPO_ROOT/pcsx2/3rdparty/soundtouch" ]; then
    build_lib "soundtouch" "$REPO_ROOT/pcsx2/3rdparty/soundtouch" \
        -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS"
else
    echo "WARNING: soundtouch source not found in 3rdparty"
fi

# cubeb
if [ -d "$REPO_ROOT/pcsx2/3rdparty/cubeb" ]; then
    build_lib "cubeb" "$REPO_ROOT/pcsx2/3rdparty/cubeb" \
        -DBUILD_TESTS=OFF -DBUILD_TOOLS=OFF -DUSE_SANITIZERS=OFF
else
    echo "WARNING: cubeb source not found in 3rdparty"
fi

echo ""
echo "=== Verifying build output ==="
ls -la "$INSTALL_DIR/lib/"*.a 2>/dev/null || echo "No .a files found — check build logs"
echo ""
echo "=== iOS dependency build complete ==="
