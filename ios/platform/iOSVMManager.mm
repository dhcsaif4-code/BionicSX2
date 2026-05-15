// PORTED FROM: VMManager.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 2.3-ADDENDUM (2.3-E, 2.3-F), 6.2, 12.2
// STATUS: NEW
#import <Foundation/Foundation.h>
#include "VMManager.h"
#include "GS/GS.h"
#include "pcsx2/Memory.h"
#include "pcsx2/R5900.h"
#include "pcsx2/Hw.h"
#include "pcsx2/Vif_Dynarec.h"
#include "pcsx2/CDVD/CDVD.h"
#include "pcsx2/Config.h"
#include "Pcsx2Config.h"

namespace iOSVMManager {

bool StartVM(const char* isoPath) {
    static bool s_initialized = false;
    if (s_initialized) return true;
    s_initialized = true;

    // Step 1: disable JIT — belt-and-suspenders (Audit Sec 2.3-F)
    EmuConfig.EE.newVifDynarec         = false;
    EmuConfig.Cpu.Recompiler.EnableEE  = false;
    EmuConfig.Cpu.Recompiler.EnableVU0 = false;
    EmuConfig.Cpu.Recompiler.EnableVU1 = false;
    EmuConfig.Cpu.Recompiler.EnableIOP = false;
    EmuConfig.GS.Renderer              = GSRendererType::Metal;
    EmuConfig.Cpu.sseMXCSR.bitmask     = 0;

    // Step 2: allocate emulated memory — MUST be first (Audit Sec 2.3-E)
    if (!SysMemory::Allocate()) {
        NSLog(@"[BionicSX2] SysMemory::Allocate() failed");
        return false;
    }

    // Step 3: reset CPU state → hwReset → vif0Reset/vif1Reset (Audit Sec 2.3-F)
    cpuReset();

    // Step 4: initialize GS Metal backend (Audit Sec 4.1)
    if (!GSopen(nullptr, "Metal", 0)) {
        NSLog(@"[BionicSX2] GSopen failed");
        SysMemory::Release();
        s_initialized = false;
        return false;
    }

    // Step 5: load disc/ISO (Audit Sec 2.6)
    if (isoPath) {
        CDVDsys_SetFile(CDVD_SourceType::Iso, isoPath);
        CDVDsys_ChangeSource(CDVD_SourceType::Iso);
    }

    return true;
}

void StopVM() {
    GSclose();
    SysMemory::Release();
}

} // namespace iOSVMManager
