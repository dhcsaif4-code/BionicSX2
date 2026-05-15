#!/usr/bin/env bash
# AUDIT REFERENCE: Section 10.2, 10.3
# STATUS: NEW
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== BionicSX2: Building main target ==="

# Ensure deps are built
if [ ! -d "$REPO_ROOT/ios-deps/install/lib" ]; then
    echo "Building iOS dependencies first..."
    bash "$REPO_ROOT/scripts/build_ios_deps.sh"
fi

# Configure
echo ">>> Configuring with CMake..."
cmake -S "$REPO_ROOT" -B "$REPO_ROOT/build-ios" \
    -DCMAKE_TOOLCHAIN_FILE="$REPO_ROOT/cmake/ios.toolchain.cmake" \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_QT=OFF \
    -DENABLE_OPENGL=OFF \
    -DENABLE_VULKAN=OFF \
    -DUSE_SDL=OFF \
    -DBUILD_TESTS=OFF

# Build
echo ">>> Building..."
cmake --build "$REPO_ROOT/build-ios" --config Release -j"$(sysctl -n hw.logicalcpu)"

echo "=== Build complete ==="
echo "Output: $REPO_ROOT/build-ios/"
