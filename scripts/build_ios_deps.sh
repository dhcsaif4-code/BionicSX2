#!/bin/bash
set -euxo pipefail

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
ARCH="arm64"
MIN_IOS="16.0"
ROOT="$(pwd)"
INSTALL_DIR="$ROOT/ios-deps/install"
BUILD_DIR="$ROOT/ios-deps/build"
mkdir -p "$INSTALL_DIR" "$BUILD_DIR"

CMAKE_IOS_FLAGS=(
  -DCMAKE_SYSTEM_NAME=iOS
  -DCMAKE_OSX_ARCHITECTURES=$ARCH
  -DCMAKE_OSX_SYSROOT=$SDK
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS
  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
  -DBUILD_SHARED_LIBS=OFF
)

build_lib() {
  local NAME=$1
  local SRC=$2
  local EXTRA_FLAGS="${@:3}"

  if [ ! -d "$SRC" ]; then
    echo "SKIP: $NAME — source not found at $SRC"
    return 0
  fi

  echo "=== Building $NAME from $SRC ==="
  mkdir -p "$BUILD_DIR/$NAME"
  cd "$BUILD_DIR/$NAME"
  cmake "$SRC" "${CMAKE_IOS_FLAGS[@]}" $EXTRA_FLAGS
  make -j$(sysctl -n hw.logicalcpu)
  make install
  cd "$ROOT"
}

# Find each library dynamically — check multiple possible locations
find_src() {
  local NAME=$1
  shift
  for PATH_CANDIDATE in "$@"; do
    if [ -d "$PATH_CANDIDATE" ]; then
      echo "$PATH_CANDIDATE"
      return 0
    fi
  done
  echo ""
}

ZLIB=$(find_src zlib \
  "$ROOT/ios-deps/src/zlib")

ZSTD=$(find_src zstd \
  "$ROOT/ios-deps/src/zstd/build/cmake")

LZ4=$(find_src lz4 \
  "$ROOT/ios-deps/src/lz4/build/cmake")

LZMA=$(find_src lzma \
  "$ROOT/ios-deps/src/xz")

FREETYPE=$(find_src freetype \
  "$ROOT/ios-deps/src/freetype")

LIBZIP=$(find_src libzip \
  "$ROOT/ios-deps/src/libzip")

build_lib zlib "$ZLIB"
build_lib zstd "$ZSTD" -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF
build_lib lz4  "$LZ4"  -DLZ4_BUILD_CLI=OFF
build_lib lzma "$LZMA"
build_lib freetype "$FREETYPE" -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BZIP2=ON
build_lib libzip "$LIBZIP" \
  -DBUILD_TOOLS=OFF \
  -DBUILD_REGRESS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_DOC=OFF

echo "=== Built libraries ==="
find "$INSTALL_DIR/lib" -name "*.a" | sort
