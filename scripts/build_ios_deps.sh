#!/bin/bash
set -euxo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
INSTALL="$ROOT/ios-deps/install"
SRC="$ROOT/ios-deps/src"
BLD="$ROOT/ios-deps/build"
mkdir -p "$INSTALL" "$SRC" "$BLD"
mkdir -p "$INSTALL/lib"
mkdir -p "$INSTALL/include"
touch "$INSTALL/include/.keep"
touch "$INSTALL/lib/.keep"

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
[ -d zlib ] || git clone --depth 1 \
  https://github.com/madler/zlib.git
mkdir -p "$BLD/zlib" && cd "$BLD/zlib"
cmake "$SRC/zlib" $FLAGS -DZLIB_BUILD_EXAMPLES=OFF
make -j$(sysctl -n hw.logicalcpu)
find . -name "libz.a" -exec cp {} "$INSTALL/lib/" \;
cp "$SRC/zlib"/*.h "$INSTALL/include/" 2>/dev/null || true
find "$BLD/zlib" -name "zconf.h" \
  -exec cp {} "$INSTALL/include/" \; 2>/dev/null || true

# ── libpng ────────────────────────────────────────────
cd "$SRC"
[ -d libpng ] || git clone --depth 1 \
  https://github.com/glennrp/libpng.git
mkdir -p "$BLD/libpng2" && cd "$BLD/libpng2"
cmake "$SRC/libpng" $FLAGS \
  -DPNG_SHARED=OFF \
  -DPNG_STATIC=ON \
  -DPNG_TESTS=OFF \
  -DPNG_FRAMEWORK=OFF \
  -DZLIB_INCLUDE_DIR="$INSTALL/include" \
  -DZLIB_LIBRARY="$INSTALL/lib/libz.a"
make -j$(sysctl -n hw.logicalcpu)
find . -name "libpng*.a" -exec cp {} "$INSTALL/lib/libpng.a" \;
cp "$SRC/libpng/png.h" "$INSTALL/include/" 2>/dev/null || true
cp "$SRC/libpng/pngconf.h" "$INSTALL/include/" 2>/dev/null || true
find "$BLD/libpng2" -name "pnglibconf.h" \
  -exec cp {} "$INSTALL/include/" \; 2>/dev/null || true

# ── zstd ──────────────────────────────────────────────
cd "$SRC"
[ -d zstd ] || git clone --depth 1 https://github.com/facebook/zstd.git
mkdir -p "$BLD/zstd" && cd "$BLD/zstd"
cmake "$SRC/zstd/build/cmake" $FLAGS \
  -DZSTD_BUILD_PROGRAMS=OFF \
  -DZSTD_BUILD_SHARED=OFF
make -j$(sysctl -n hw.logicalcpu)
find . -name "*.a" -exec cp {} "$INSTALL/lib/" \;
cp "$SRC/zstd/lib/zstd.h" "$INSTALL/include/" 2>/dev/null || true
cp "$SRC/zstd/lib/zstd_errors.h" "$INSTALL/include/" 2>/dev/null || true
cp "$SRC/zstd/lib/zdict.h" "$INSTALL/include/" 2>/dev/null || true

# ── lz4 ───────────────────────────────────────────────
cd "$SRC"
[ -d lz4 ] || git clone --depth 1 \
  https://github.com/lz4/lz4.git
mkdir -p "$BLD/lz4" && cd "$BLD/lz4"
cmake "$SRC/lz4/build/cmake" $FLAGS \
  -DLZ4_BUILD_CLI=OFF \
  -DLZ4_BUILD_LEGACY_LZ4C=OFF
make -j$(sysctl -n hw.logicalcpu)
find . -name "liblz4.a" -exec cp {} "$INSTALL/lib/" \;
cp "$SRC/lz4/lib/lz4.h" "$INSTALL/include/" 2>/dev/null || true
cp "$SRC/lz4/lib/lz4hc.h" "$INSTALL/include/" 2>/dev/null || true
cp "$SRC/lz4/lib/lz4frame.h" "$INSTALL/include/" 2>/dev/null || true

# ── xz/lzma ───────────────────────────────────────────
cd "$SRC"
[ -d xz ] || git clone --depth 1 \
  https://github.com/tukaani-project/xz.git
mkdir -p "$BLD/xz2" && cd "$BLD/xz2"
cmake "$SRC/xz" $FLAGS -DBUILD_TESTING=OFF
make -j$(sysctl -n hw.logicalcpu)
find . -name "liblzma.a" -exec cp {} "$INSTALL/lib/" \;
# Copy lzma headers correctly
mkdir -p "$INSTALL/include/lzma"

# Copy all sub-headers first
find "$SRC/xz/src/liblzma/api/lzma" -name "*.h" \
  -exec cp {} "$INSTALL/include/lzma/" \;

# Copy the main umbrella header last
cp "$SRC/xz/src/liblzma/api/lzma.h" \
  "$INSTALL/include/lzma.h"

# Verify
ls "$INSTALL/include/lzma.h" && echo "lzma.h OK"
ls "$INSTALL/include/lzma/" | head -5

# ── freetype ──────────────────────────────────────────
cd "$SRC"
[ -d freetype ] || git clone --depth 1 \
  https://gitlab.freedesktop.org/freetype/freetype.git
mkdir -p "$BLD/freetype" && cd "$BLD/freetype"
cmake "$SRC/freetype" $FLAGS \
  -DFT_DISABLE_HARFBUZZ=ON \
  -DFT_DISABLE_BZIP2=ON \
  -DFT_DISABLE_PNG=OFF \
  -DZLIB_INCLUDE_DIR="$INSTALL/include" \
  -DZLIB_LIBRARY="$INSTALL/lib/libz.a" \
  -DPNG_PNG_INCLUDE_DIR="$INSTALL/include" \
  -DPNG_LIBRARY="$INSTALL/lib/libpng.a"
make -j$(sysctl -n hw.logicalcpu)
find . -name "libfreetype.a" -exec cp {} "$INSTALL/lib/" \;
mkdir -p "$INSTALL/include/freetype2"
cp -r "$SRC/freetype/include/freetype" \
  "$INSTALL/include/freetype2/" 2>/dev/null || true
cp "$SRC/freetype/include/ft2build.h" \
  "$INSTALL/include/" 2>/dev/null || true

# ── soundtouch ────────────────────────────────────────
cd "$SRC"
[ -d soundtouch ] || git clone --depth 1 \
  https://codeberg.org/soundtouch/soundtouch.git

ST_SRC="$SRC/soundtouch/source/SoundTouch"
ST_OUT="$INSTALL/lib/libsoundtouch.a"
ST_INC="$SRC/soundtouch/include"
ST_OBJ="$BLD/soundtouch"
mkdir -p "$ST_OBJ" "$INSTALL/lib" "$INSTALL/include/soundtouch"

# Verify sources exist
echo "SoundTouch sources:"
ls "$ST_SRC" || echo "DIR NOT FOUND: $ST_SRC"

OBJS=()
for f in "$ST_SRC"/*.cpp; do
  echo "Compiling: $f"
  OBJ="$ST_OBJ/$(basename ${f%.cpp}).o"
  xcrun clang++ \
    -target arm64-apple-ios16.0 \
    -isysroot "$(xcrun --sdk iphoneos --show-sdk-path)" \
    -I"$ST_INC" \
    -std=c++17 -O2 -c "$f" -o "$OBJ" 2>&1
  if [ -f "$OBJ" ]; then
    OBJS+=("$OBJ")
    echo "OK: $OBJ"
  else
    echo "FAILED: $OBJ"
  fi
done

echo "Total objects: ${#OBJS[@]}"

if [ ${#OBJS[@]} -eq 0 ]; then
  echo "ERROR: No soundtouch objects compiled"
  # Try cmake fallback
  mkdir -p "$BLD/soundtouch_cmake" && cd "$BLD/soundtouch_cmake"
  cmake "$SRC/soundtouch" $FLAGS \
    -DCMAKE_CXX_STANDARD=17
  make -j$(sysctl -n hw.logicalcpu) || true
  find . -name "*.a" -exec cp {} "$INSTALL/lib/libsoundtouch.a" \; || true
else
  xcrun ar rcs "$ST_OUT" "${OBJS[@]}"
fi

cp "$ST_INC"/*.h "$INSTALL/include/soundtouch/" 2>/dev/null || true
echo "Result: $(find $INSTALL/lib -name '*soundtouch*' 2>/dev/null)"

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
  # Skip libretro integration — not needed for PCSX2
  [[ "$f" == *"rc_libretro"* ]] && continue
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
make -j$(sysctl -n hw.logicalcpu)
find . -name "*.a" -exec cp {} "$INSTALL/lib/" \;

# ── Final verification ────────────────────────────────
echo "=== Built libraries ==="
find "$INSTALL/lib" -name "*.a" | sort
echo "=== Key headers ==="
ls "$INSTALL/include/png.h" 2>/dev/null && echo "png.h OK" || echo "png.h MISSING"
ls "$INSTALL/include/ft2build.h" 2>/dev/null && echo "ft2build.h OK" || echo "ft2build.h MISSING"
ls "$INSTALL/include/lzma.h" 2>/dev/null && echo "lzma.h OK" || echo "lzma.h MISSING"

echo "=== Done ==="
