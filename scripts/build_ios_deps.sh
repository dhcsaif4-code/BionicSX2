#!/bin/bash
set -euxo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
ARCH="arm64"
MIN_IOS="16.0"
INSTALL_DIR="$REPO_ROOT/ios-deps/install"
SRC_DIR="$REPO_ROOT/ios-deps/src"
BUILD_DIR="$REPO_ROOT/ios-deps/build"
mkdir -p "$INSTALL_DIR/lib" "$INSTALL_DIR/include" "$SRC_DIR" "$BUILD_DIR"

CMAKE_IOS_FLAGS="-DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES=$ARCH \
  -DCMAKE_OSX_SYSROOT=$SDK \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release"

build_lib() {
  local NAME="$1"
  local SRC="$2"
  shift 2
  mkdir -p "$BUILD_DIR/$NAME"
  cmake -S "$SRC" -B "$BUILD_DIR/$NAME" \
    $CMAKE_IOS_FLAGS \
    "$@"
  cmake --build "$BUILD_DIR/$NAME" --config Release -j"$(sysctl -n hw.logicalcpu)"
  cmake --install "$BUILD_DIR/$NAME"
  echo ">>> $NAME OK"
}

# zlib
build_lib "zlib" "$REPO_ROOT/pcsx2/3rdparty/zlib" \
  -DZLIB_BUILD_EXAMPLES=OFF

# zstd
build_lib "zstd" "$REPO_ROOT/pcsx2/3rdparty/zstd/build/cmake" \
  -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON

# lz4
build_lib "lz4" "$REPO_ROOT/pcsx2/3rdparty/lz4/build/cmake" \
  -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF

# lzma/xz
build_lib "lzma" "$REPO_ROOT/pcsx2/3rdparty/lzma" \
  -DCMAKE_C_FLAGS="-mcpu=apple-a14"

# freetype
build_lib "freetype" "$REPO_ROOT/pcsx2/3rdparty/freetype" \
  -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_BROTLI=ON

# libpng
build_lib "libpng" "$REPO_ROOT/pcsx2/3rdparty/libpng" \
  -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF

# libzip
build_lib "libzip" "$REPO_ROOT/pcsx2/3rdparty/libzip" \
  -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF \
  -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF -DENABLE_OPENSSL=OFF

# soundtouch
build_lib "soundtouch" "$REPO_ROOT/pcsx2/3rdparty/soundtouch" \
  -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS"

echo "=== Built libraries ==="
find "$INSTALL_DIR/lib" -name "*.a" | sort
