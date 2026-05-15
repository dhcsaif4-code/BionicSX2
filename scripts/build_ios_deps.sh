#!/bin/bash
set -euxo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
INSTALL="$ROOT/ios-deps/install"
SRC="$ROOT/ios-deps/src"
BLD="$ROOT/ios-deps/build"
mkdir -p "$INSTALL" "$SRC" "$BLD"

FLAGS="\
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_SYSROOT=$SDK \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DBUILD_SHARED_LIBS=OFF"

# ── zlib ──────────────────────────────────────────────
cd "$SRC"
[ -d zlib ] || git clone --depth 1 https://github.com/madler/zlib.git
mkdir -p "$BLD/zlib" && cd "$BLD/zlib"
cmake "$SRC/zlib" $FLAGS
make -j$(sysctl -n hw.logicalcpu) install

# ── libpng ────────────────────────────────────────────
cd "$SRC"
[ -d libpng ] || git clone --depth 1 \
  https://github.com/glennrp/libpng.git
mkdir -p "$BLD/libpng" && cd "$BLD/libpng"
cmake "$SRC/libpng" $FLAGS \
  -DPNG_SHARED=OFF \
  -DPNG_STATIC=ON \
  -DPNG_TESTS=OFF \
  -DZLIB_ROOT="$INSTALL"
make -j$(sysctl -n hw.logicalcpu) install

# ── zstd ──────────────────────────────────────────────
cd "$SRC"
[ -d zstd ] || git clone --depth 1 https://github.com/facebook/zstd.git
mkdir -p "$BLD/zstd" && cd "$BLD/zstd"
cmake "$SRC/zstd/build/cmake" $FLAGS \
  -DZSTD_BUILD_PROGRAMS=OFF \
  -DZSTD_BUILD_SHARED=OFF
make -j$(sysctl -n hw.logicalcpu) install

# ── lz4 ───────────────────────────────────────────────
cd "$SRC"
[ -d lz4 ] || git clone --depth 1 https://github.com/lz4/lz4.git
mkdir -p "$BLD/lz4" && cd "$BLD/lz4"
cmake "$SRC/lz4/build/cmake" $FLAGS \
  -DLZ4_BUILD_CLI=OFF \
  -DLZ4_BUILD_LEGACY_LZ4C=OFF
make -j$(sysctl -n hw.logicalcpu) install

# ── xz/lzma ───────────────────────────────────────────
cd "$SRC"
[ -d xz ] || git clone --depth 1 \
  https://github.com/tukaani-project/xz.git
mkdir -p "$BLD/xz" && cd "$BLD/xz"
cmake "$SRC/xz" $FLAGS \
  -DBUILD_TESTING=OFF
make -j$(sysctl -n hw.logicalcpu) install

# ── freetype ──────────────────────────────────────────
cd "$SRC"
[ -d freetype ] || git clone --depth 1 \
  https://gitlab.freedesktop.org/freetype/freetype.git
mkdir -p "$BLD/freetype" && cd "$BLD/freetype"
cmake "$SRC/freetype" $FLAGS \
  -DFT_DISABLE_HARFBUZZ=ON \
  -DFT_DISABLE_BZIP2=ON \
  -DFT_DISABLE_PNG=OFF \
  -DZLIB_ROOT="$INSTALL"
make -j$(sysctl -n hw.logicalcpu) install

# ── soundtouch ────────────────────────────────────────
cd "$SRC"
[ -d soundtouch ] || git clone --depth 1 \
  https://codeberg.org/soundtouch/soundtouch.git
mkdir -p "$BLD/soundtouch" && cd "$BLD/soundtouch"
cmake "$SRC/soundtouch" $FLAGS \
  -DSOUNDTOUCH_BUILD_SHARED_LIBS=OFF
make -j$(sysctl -n hw.logicalcpu) install

# cubeb — cannot build for iOS (macOS-only CoreAudio backend), stubbed

# ── rcheevos ──────────────────────────────────────────
cd "$SRC"
[ -d rcheevos ] || git clone --depth 1 \
  https://github.com/RetroAchievements/rcheevos.git

SDK_RC=$(xcrun --sdk iphoneos --show-sdk-path)
RC_SRC="$SRC/rcheevos/src"
RC_OUT="$INSTALL/lib/librcheevos.a"
RC_INC="$SRC/rcheevos/include"

# Compile all .c files manually
OBJ_DIR="$BLD/rcheevos"
mkdir -p "$OBJ_DIR"

OBJS=()
for f in "$RC_SRC"/rc_*.c "$RC_SRC"/rapi/*.c \
          "$RC_SRC"/rhash/*.c "$RC_SRC"/rurl/*.c; do
  [ -f "$f" ] || continue
  OBJ="$OBJ_DIR/$(basename ${f%.c}).o"
  xcrun clang \
    -target arm64-apple-ios16.0 \
    -isysroot "$SDK_RC" \
    -I"$RC_INC" \
    -O2 -c "$f" -o "$OBJ"
  OBJS+=("$OBJ")
done

xcrun ar rcs "$RC_OUT" "${OBJS[@]}"
mkdir -p "$INSTALL/include/rcheevos"
cp "$RC_INC"/*.h "$INSTALL/include/rcheevos/"
echo "rcheevos built: $(du -sh $RC_OUT)"

# ── libchdr ───────────────────────────────────────────
cd "$SRC"
[ -d libchdr ] || git clone --depth 1 \
  https://github.com/rtissera/libchdr.git
mkdir -p "$BLD/libchdr" && cd "$BLD/libchdr"
cmake "$SRC/libchdr" $FLAGS \
  -DWITH_SYSTEM_ZLIB=ON \
  -DZLIB_ROOT="$INSTALL"
make -j$(sysctl -n hw.logicalcpu) install

echo "=== Done ==="
find "$INSTALL/lib" -name "*.a" | sort
