# BionicSX2 Build System — Anchored Session Summary

## Repo Context
- **BionicSX2**: iOS port of PCSX2 (PS2 emulator). Workspace at `/workspaces/BionicSX2`.
- **Current HEAD**: `2b0f9c8` (on `main`, pushed to `origin/main`).
- **Phase 0**: iOS bring-up — integrating real PCSX2 C++ sources into an iOS Xcode project via CMake + XcodeGen.

---

## Architecture

### Two-target CMake build
1. **BionicSX2** (STATIC library) — `libBionicSX2.a`, contains ~300+ real `.o` files compiled from PCSX2 tree.
2. **BionicSX2_App** (executable) — the iOS app bundle. Links libBionicSX2.a + stubs. This is the `ios/` target.

The stub files (`MissingSymbols.mm`, `AppStubs.mm`, `CStubs.c`) are compiled into BionicSX2_App (not the static lib) so they provide the last-resort symbols needed at link time.

### Key directories
- `pcsx2/` — upstream PCSX2 source tree (many submodules are empty stubs)
- `ios/platform/` — iOS-specific implementations and stubs
- `ios/ui/` — SwiftUI view layer

---

## Build Configuration (Phase 0-D2)

### CMakeLists.txt key sections
- **COMMON_DIR** = `${CMAKE_SOURCE_DIR}/pcsx2/common`
- **PCSX2_CORE_SOURCES**: ~60+ files from pcsx2 tree — compiled into the static lib
- **PCSX2_SPU2_SOURCES**: nullSnd + record-zer (stub audio drivers)
- **PCSX2_PLATFORM_SOURCES**: GS/Host platform files from pcsx2 tree
- **IOS_PLATFORM_SOURCES**: `ios/platform/` C++/ObjC++ files (compiled into static lib)
- **IOS_METAL_SOURCES**: Metal renderer files from pcsx2/GS/Renderers/Metal
- **IOS_SWIFT_SOURCES**: Swift UI layer
- Conditional sources: `Log.cpp` (stub check), `fmt` (stub check), `liblzma` (stub check)
- Flags: `-Wno-ambiguous-member-template`, C++20, ObjC ARC enabled for `.mm` files

### XcodeGen project at `ios/project.yml`
- Defines `BionicSX2_App` iOS app target
- Uses `xcodegen` to generate `.xcodeproj`

---

## Stub Files — Map

| File | Purpose | Target |
|---|---|---|
| `ios/platform/MissingSymbols.mm` | Stubs for iOS-dead-code paths (RGBA8Image, Cubeb, SDL audio, Xz, Zstd, vTlb) | BionicSX2_App |
| `ios/platform/AppStubs.mm` | C++-linkage stubs for symbols referenced by libBionicSX2.a (USB, DEV9, VIF, Discord, aligned alloc, FullscreenUI, etc.) | BionicSX2_App |
| `ios/platform/SymbolStubs.cpp` | Small C++ stubs + asm stubs compiled into libBionicSX2.a (GSDrawScanline, GSVector4i, GSScanlineLocalData) | BionicSX2 |
| `ios/platform/CStubs.c` | (Deleted) — Was C-linkage stubs, removed after moving to AppStubs.mm to fix ABI mismatch | — |
| `ios/platform/Host_iOS.mm` | Real Host:: implementations (settings, OSD, translation, etc.) compiled into libBionicSX2.a | BionicSX2 |
| `ios/platform/iOSHost.mm` | Minimal Host:: stubs for functions the iOS UI target needs | BionicSX2_App |

---

## Fix Groups Applied This Session

### Group 1 — GSDrawScanline stubs (MissingSymbols.mm)
**Problem**: `isa_native::GSDrawScanline` symbols resolved via stubs in MissingSymbols.mm, but the real pcsx2 GS SW rasterizer (compiled into libBionicSX2.a) provides them now → link conflict.
**Fix**: Removed the entire GROUP B section (lines 28–59) from MissingSymbols.mm.
**Files**: `ios/platform/MissingSymbols.mm`

### Group 2 — dVif/DEV9 C++ stubs (AppStubs.mm)
**Problem**: `dVifRelease`, `dVifReset`, `DEV9CheckChanges` were stubbed in AppStubs.mm but now provided by real compilation in libBionicSX2.a.
**Fix**: Removed lines 35–41 (the three stubs + their comment header).
**Files**: `ios/platform/AppStubs.mm`

### Group 3 — Image.cpp HEADER_FILE_ONLY (CMakeLists.txt)
**Problem**: `pcsx2/common/Image.cpp` uses webp/jpeg libs unavailable on iOS. Was commented out so indexer couldn't see it.
**Fix**: Uncommented it in PCSX2_CORE_SOURCES and added `set_source_files_properties(... HEADER_FILE_ONLY TRUE)` after `add_library()` so Xcode's indexer sees it but the compiler skips it. `Image_iOS.cpp` provides the iOS implementation.
**Files**: `CMakeLists.txt`

### Group 4 — iOSHost.mm duplicate removal
**Problem**: `iOSHost.mm` defined `InputBindingKey{}` (conflicts with real pcsx2/Host.h definition) and had 3 functions (`ShouldPreferHostFileSelector`, `OpenHostFileSelectorAsync`, `OnAchievementsLoginRequested`) that are already in `Host_iOS.mm` → duplicate symbol errors.
**Fix**: Removed `struct InputBindingKey {};` forward decl + the three duplicate function bodies.
**Files**: `ios/platform/iOSHost.mm`

---

## Notable Past Commits (preceding HEAD)
| Hash | Message |
|---|---|
| `325eb37` | fix(linking): move GSScanlineLocalData to global namespace — fixes mangling R19 vs RNS_19 |
| `03d4547` | fix(linking): force out-of-line emission for GSDrawScanline + applyGameFixes |
| `bcdf615` | debug: show ALL T symbols from SymbolStubs without grep filter |
| `4603571` | debug: capture compile errors from SymbolStubs + show file content on failure |
| `5071d32` | debug: use iphoneos SDK explicitly for SymbolStubs inspection |
| `06deea8` | debug: compile SymbolStubs standalone to inspect mangled names |
| `d06c332` | debug: dump exported vs required symbols side by side |
| `8a50c28` | fix(compile): move GSVector4i/GSVertexSW declarations before isa_native namespace |
| `c823bc4` | fix(linking): fix GSDrawScanline namespace mangling + add nm export dump |
| `9ec8a48` | fix(ci): move nm dump steps to AFTER make build step |

---

## GSDrawScanline/Linking Saga (key learnings)
- The `GSDrawScanline` class in the pcsx2 GS SW rasterizer uses `isa_native` namespace
- Swift/clang++ mangles `isa_native::GSScanlineLocalData` as `R19` (global namespace ref) not `RNS_19` (nested namespace ref) because `isa_native` is declared as `namespace isa_native { ... }` not `namespace isa { namespace native { ... } }`
- SymbolStubs.cpp provides `GSDrawScanline` with out-of-line key methods to force emission into the static lib
- The original isa_native stubs in MissingSymbols.mm (BionicSX2_App target) conflicted once SymbolStubs.cpp (BionicSX2 lib target) provided the same symbols → Group 1 fix
- `nm` / `objdump` (from Xcode toolchain) was used extensively to debug mangled names
- Apple's `otool` and `nm` are at `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/`

---

## Build incantation
```bash
# Inside ios/ directory:
make clean && make 2>&1 | tail -100
# or with Xcode:
open BionicSX2.xcodeproj
```

---

## Open/known issues
- Several PCSX2 submodules are empty stubs → `Pcsx2Types.h`, `fmt`, `liblzma` all have fallback paths in CMake
- `Image.cpp` is HEADER_FILE_ONLY (see Group 3) — if the actual file doesn't exist in the submodule, the conditional guard silently skips it
- `InputBindingKey` type — real definition comes from pcsx2/Host.h; AppStubs.mm has its own forward decl (needed because AppStubs.mm doesn't include the real header)
- `OnInputDeviceDisconnected(InputBindingKey, ...)` in iOSHost.mm depends on InputBindingKey being defined by the pcsx2/Host.h include
