// PORTED FROM: VMManager.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 2.3-ADDENDUM (2.3-E, 2.3-F), 6.2, 12.2
// STATUS: NEW
#import <Foundation/Foundation.h>
#include "VMManager.h"
#include "GS/GS.h"
#include "pcsx2/Memory.h"
#include "pcsx2/R5900.h"
#include "pcsx2/Hw.h"
#include "pcsx2/CDVD/CDVD.h"
#include "pcsx2/ps2/BiosTools.h"
#include "Config.h"
#include "common/Console.h"
#include "common/FileSystem.h"
#include "pcsx2/Vif_Dynarec.h"
#include "Filesystem_iOS.h"
#include "LogOverlay.h"

namespace iOSVMManager {

bool StartVM(const char* isoPath) {
    static bool s_initialized = false;
    if (s_initialized) return true;
    s_initialized = true;

    BXLog(@"=== VM Start ===");

    // Step 0: override DataRoot to iOS Documents directory so all paths
    // (BIOS, memcards, savestates) point inside the app sandbox where
    // the user can access them via iTunes File Sharing.
    {
        std::string docs = iOSGetDocumentsDirectory();
        EmuFolders::DataRoot = docs;
        EmuFolders::Bios = iOSGetBIOSPath();
        EmuFolders::MemoryCards = iOSGetMemcardPath();
        FileSystem::EnsureDirectoryExists(EmuFolders::Bios.c_str(), false, nullptr);
        FileSystem::EnsureDirectoryExists(EmuFolders::MemoryCards.c_str(), false, nullptr);
        BXLog(@"DataRoot: %s", docs.c_str());
        BXLog(@"BIOS dir: %s", EmuFolders::Bios.c_str());
    }

    // Step 1: disable JIT — belt-and-suspenders (Audit Sec 2.3-F)
    EmuConfig.Cpu.Recompiler.EnableEE  = false;
    EmuConfig.Cpu.Recompiler.EnableVU0 = false;
    EmuConfig.Cpu.Recompiler.EnableVU1 = false;
    EmuConfig.Cpu.Recompiler.EnableIOP = false;
    EmuConfig.GS.Renderer              = GSRendererType::Metal;

    // Step 2: allocate emulated memory — MUST be first (Audit Sec 2.3-E)
    BXLog(@"Allocating emulated memory...");
    if (!SysMemory::Allocate()) {
        BXLogError(@"SysMemory::Allocate() failed");
        s_initialized = false;
        return false;
    }
    BXLog(@"SysMemory::Allocate() OK");

    // Step 3: load BIOS (Audit Sec 2.3 — required before cpuReset)
    BXLog(@"Loading BIOS from %s ...", EmuFolders::Bios.c_str());
    if (!LoadBIOS()) {
        BXLogError(@"LoadBIOS() failed — no valid BIOS found in %s", EmuFolders::Bios.c_str());
        BXLogError(@"Place a PS2 BIOS file (e.g. SCPH-39001.bin) in the app's BIOS folder via iTunes File Sharing.");
        SysMemory::Release();
        s_initialized = false;
        return false;
    }
    BXLog(@"LoadBIOS() OK");

    // Step 4: reset memory — this calls memReset() → CopyBIOSToMemory()
    BXLog(@"Resetting system memory...");
    SysMemory::Reset();
    BXLog(@"SysMemory::Reset() OK");

    // Step 5: force interpreter — belt-and-suspenders (Audit Sec 2.3-F)
    BXLog(@"CPU — forcing interpreter mode (no JIT)");

    // Step 6a: ensure CDVD pointer is valid before any reset touches it
    if (isoPath) {
        CDVDsys_SetFile(CDVD_SourceType::Iso, isoPath);
        CDVDsys_ChangeSource(CDVD_SourceType::Iso);
    } else {
        CDVDsys_ChangeSource(CDVD_SourceType::NoDisc);
    }

    // Step 6b: reset CPU state → hwReset → vif0Reset/vif1Reset (Audit Sec 2.3-F)
    BXLog(@"Resetting CPU...");
    @try {
        cpuReset();
        BXLog(@"cpuReset() OK");
    } @catch (NSException *e) {
        BXLogError(@"cpuReset() threw exception: %@ — reason: %@", e.name, e.reason);
        SysMemory::Release();
        s_initialized = false;
        return false;
    }

    // Step 7: initialize GS Metal backend (Audit Sec 4.1)
    BXLog(@"Opening GS Metal backend...");
    BXLog(@"MetalRenderer: step H — calling GSopen (ImGui + renderer init)");
    @try {
        if (!GSopen(EmuConfig.GS, GSRendererType::Metal, nullptr, GSVSyncMode::Disabled, false)) {
            BXLogError(@"GSopen() failed");
            SysMemory::Release();
            s_initialized = false;
            return false;
        }
    } @catch (NSException *e) {
        BXLogError(@"MetalRenderer EXCEPTION in GSopen: %@ — %@", e.name, e.reason);
        SysMemory::Release();
        s_initialized = false;
        return false;
    }
    BXLog(@"MetalRenderer: step H done — GSopen() returned true");
    BXLog(@"=== VM Start complete ===");
    return true;
}

void StopVM() {
    GSclose();
    SysMemory::Release();
}

} // namespace iOSVMManager
