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

namespace iOSVMManager {

bool StartVM(const char* isoPath) {
    static bool s_initialized = false;
    if (s_initialized) return true;
    s_initialized = true;

    NSLog(@"[BionicSX2] === VM Start ===");

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
        NSLog(@"[BionicSX2] DataRoot: %s", docs.c_str());
        NSLog(@"[BionicSX2] BIOS dir: %s", EmuFolders::Bios.c_str());
    }

    // Step 1: disable JIT — belt-and-suspenders (Audit Sec 2.3-F)
    EmuConfig.Cpu.Recompiler.EnableEE  = false;
    EmuConfig.Cpu.Recompiler.EnableVU0 = false;
    EmuConfig.Cpu.Recompiler.EnableVU1 = false;
    EmuConfig.Cpu.Recompiler.EnableIOP = false;
    EmuConfig.GS.Renderer              = GSRendererType::Metal;

    // Step 2: allocate emulated memory — MUST be first (Audit Sec 2.3-E)
    NSLog(@"[BionicSX2] Allocating emulated memory...");
    if (!SysMemory::Allocate()) {
        NSLog(@"[BionicSX2] FAILED: SysMemory::Allocate()");
        s_initialized = false;
        return false;
    }
    NSLog(@"[BionicSX2] SysMemory::Allocate() OK");

    // Step 3: load BIOS (Audit Sec 2.3 — required before cpuReset)
    // Scans EmuFolders::Bios (Documents/BIOS/) for a valid PS2 BIOS file.
    NSLog(@"[BionicSX2] Loading BIOS from %s ...", EmuFolders::Bios.c_str());
    if (!LoadBIOS()) {
        NSLog(@"[BionicSX2] FAILED: LoadBIOS() — no valid BIOS found in %s", EmuFolders::Bios.c_str());
        NSLog(@"[BionicSX2] Place a PS2 BIOS file (e.g. SCPH-39001.bin) in the app's BIOS folder via iTunes File Sharing.");
        SysMemory::Release();
        s_initialized = false;
        return false;
    }
    NSLog(@"[BionicSX2] LoadBIOS() OK");

    // Step 4: reset memory — this calls memReset() → CopyBIOSToMemory()
    // which copies the loaded BiosRom into eeMem->ROM.
    NSLog(@"[BionicSX2] Resetting system memory...");
    SysMemory::Reset();
    NSLog(@"[BionicSX2] SysMemory::Reset() OK");

    // Step 5: reset CPU state → hwReset → vif0Reset/vif1Reset (Audit Sec 2.3-F)
    NSLog(@"[BionicSX2] Resetting CPU...");
    cpuReset();
    NSLog(@"[BionicSX2] cpuReset() OK");

    // Step 6: initialize GS Metal backend (Audit Sec 4.1)
    NSLog(@"[BionicSX2] Opening GS Metal backend...");
    if (!GSopen(EmuConfig.GS, GSRendererType::Metal, nullptr, GSVSyncMode::Disabled, false)) {
        NSLog(@"[BionicSX2] FAILED: GSopen()");
        SysMemory::Release();
        s_initialized = false;
        return false;
    }
    NSLog(@"[BionicSX2] GSopen() OK");

    // Step 7: load disc/ISO (Audit Sec 2.6)
    if (isoPath) {
        NSLog(@"[BionicSX2] Loading ISO: %s", isoPath);
        CDVDsys_SetFile(CDVD_SourceType::Iso, isoPath);
        CDVDsys_ChangeSource(CDVD_SourceType::Iso);
        NSLog(@"[BionicSX2] ISO loaded OK");
    } else {
        NSLog(@"[BionicSX2] No ISO provided — running without disc");
    }

    NSLog(@"[BionicSX2] === VM Start complete ===");
    return true;
}

void StopVM() {
    GSclose();
    SysMemory::Release();
}

} // namespace iOSVMManager
