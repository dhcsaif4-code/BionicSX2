# BionicSX2 Build System — Anchored Session Summary

## Repo Context
- **BionicSX2**: iOS port of PCSX2 (PS2 emulator). Workspace at `/workspaces/BionicSX2`.
- **Current HEAD**: `10e9bcb` (on `main`, pushed to `origin/main`).
- **Phase 0**: iOS bring-up — integrating real PCSX2 C++ sources into an iOS Xcode project via CMake + XcodeGen.

---

## Architecture

### Two-target CMake build
1. **BionicSX2** (STATIC library) — `libBionicSX2.a`, contains ~300+ real `.o` files compiled from PCSX2 tree.
2. **BionicSX2_App** (executable) — the iOS app bundle. Links libBionicSX2.a + stubs. This is the `ios/` target.

### Key directories
- `pcsx2/` — upstream PCSX2 source tree
- `pcsx2/common/` — ~93 files, no `Align.h` (alignment in `BitUtils.h`)
- `ios/platform/` — iOS-specific implementations and shared state
- `ios/ui/` — SwiftUI/UIKit view layer
- `metal/` — simplified Metal renderer (custom, not upstream GSDeviceMTL)

---

## Known Issues & Decisions

### Session 2026-05-17: Black Screen → MetalRenderer init + LogOverlay

#### Root Cause
Three independent failures produced the same symptom (nil MTLDevice + nil CAMetalLayer):

1. **`MetalRenderer::Create(const WindowInfo&, string_view)` not an override** — The base class `GSDevice::Create(GSVSyncMode, bool)` was called (GS.cpp:143), just storing flags. MetalRenderer's `Create` had a **different signature**, so it was a separate overload never invoked. `m_device`, `m_commandQueue`, `m_library`, `m_presentPSO` all stayed nil.

2. **`setMetalLayer:` never called** — `MetalViewController.viewDidLoad()` configured `metalLayer` from `view.layer as? CAMetalLayer` but never called `BionicSX2Bridge.setMetalLayer(metalLayer)`. Even if called, that method built a stack-local `WindowInfo` that went nowhere — `g_metalLayer` was set but never read.

3. **`SetWindow` never called** — No code called `g_gs_device->SetWindow(wi)`. Renderer never learned its CAMetalLayer.

#### Fixes Applied

| File | Change |
|---|---|
| `metal/MetalRenderer.h` | Changed `Create(const WindowInfo&, string_view)` → `Create(GSVSyncMode, bool) override` |
| `metal/MetalRenderer.mm` | Rewrote `Create` to override base class: creates MTLDevice, command queue, reads stored WindowInfo via `BXSX2GetWindowInfo()`, configures CAMetalLayer, loads metallib, builds present PSO |
| `ios/ui/BionicSX2Bridge.mm` | Stores `WindowInfo` globally via `BXSX2SetWindowInfo`; `window_handle` + `surface_handle` now retrievable |
| `ios/platform/BionicSX2Shared.h` | **New** — C/ObjC header declaring `BXSX2SetWindowInfo`/`BXSX2GetWindowInfo` + view handle accessors |
| `ios/ui/BionicSX2Bridge.h` | Unchanged — `+setMetalLayer:` declaration still takes `CAMetalLayer*` |
| `ios/ui/MetalViewController.swift` | Calls `BionicSX2Bridge.setMetalLayer(metalLayer)` before `BionicSX2Bridge.startVM(isoPath:)` |
| `ios/ui/LogOverlay.h` | **New** — declares `BXLog`/`BXLogError` C functions + `LogOverlay` ObjC class |
| `ios/ui/LogOverlay.mm` | **New** — writes to `Documents/runtime.log` with crash-safe `fflush`/`synchronizeFile` after every write; on-screen UITextView showing last 20 lines with timestamps |
| `ios/ui/SceneDelegate.swift` | Installs LogOverlay before any UI; adds "Window created"/"UI loaded" checkpoints |
| `ios/ui/AppDelegate.mm` | Initializes `LogOverlay.shared` in `application:didFinishLaunchingWithOptions:` |
| `ios/platform/iOSVMManager.mm` | Replaced all `NSLog` → `BXLog`/`BXLogError` for persistent logging |
| `metal/MetalRenderer.mm` | Added `BXLog`/`BXLogError` at every init step with device name, dimensions, failures |
| `CMakeLists.txt` | Added `LogOverlay.mm` to `IOS_PLATFORM_SOURCES`; added `ios/ui` to `BionicSX2_App` include paths |

#### On-Screen Log Overlay
- Floating UITextView at top of screen (semi-transparent black background)
- Shows last 20 lines with `[HH:MM:SS]` timestamp prefix
- Errors shown in red text
- All lines also written to `Documents/runtime.log` via crash-safe append+flush
- New session marker: `===== APP STARTED =====`
- File accessible via iPad Files app under BionicSX2's Documents folder

#### Checkpoint Logs (matching user's format order)
1. "App launched" — AppDelegate.mm
2. "Metal device: <name>" — MetalViewController.swift (after MTLCreateSystemDefaultDevice)
3. "Window created" — SceneDelegate.swift
4. "Renderer init started" — MetalViewController.swift
5. "Metal device: <name>" / "FAILED: MTLCreateSystemDefaultDevice returned nil" — MetalRenderer::Create
6. "Surface created" / "Surface FAILED: ..." — MetalViewController.swift after startVM returns
7. "UI loaded" — SceneDelegate.swift

#### Remaining Issues
- **No emulation run loop wired** — `iOSVMManager::StartVM()` initializes all subsystems but does NOT start EE/IOP threads or MTGS. Even with BIOS loaded, the emulator will not execute game code.
- **swift `@main` vs ObjC `main.mm` conflict** — Both `BionicSX2App.swift (@main)` and `main.mm` define an entry point. Currently builds but may cause linker issues depending on toolchain version.
- **Obsolete ObjC AppDelegate window** — `AppDelegate.mm` creates an empty UIWindow with no root VC, then `SceneDelegate` creates a second window. The first window is useless but harmless.

### Past Fixes (previous sessions)
- Removed `#include "common/Align.h"` from MetalRenderer.mm
- Fixed deprecated `keyWindow` → `connectedScenes`-based lookup in BionicSX2Bridge.mm
- Added `using Format = GSTexture::Format;` and `using Type = GSTexture::Type;` in MetalRenderer.mm
- Added missing `override` to `Destroy()` in MetalRenderer.h
- Initialized pcsx2 submodule to commit `58facc8ab16c30e7dc4e56d01e08ea57d5f1c1eb`
- Created `ios/platform/Filesystem_iOS.h` for iOS path helpers
- Rewrote `iOSVMManager::StartVM()` with proper BIOS init sequence
- Added BIOS-missing alert UI in MetalViewController.swift

---

## Build incantation
```bash
# Inside ios/ directory:
make clean && make 2>&1 | tail -100
# or with Xcode:
open BionicSX2.xcodeproj
```
