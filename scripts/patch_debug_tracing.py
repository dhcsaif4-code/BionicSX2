#!/usr/bin/env python3
"""Apply per-line BLogC debug tracing to reset-path functions.

Injects a #include "BionicSX2Shared.h" and adds BLogC("...") markers
after every significant operation inside:
  - cpuReset()       (pcsx2/pcsx2/R5900.cpp)
  - psxReset()       (pcsx2/pcsx2/R3000A.cpp)
  - psxHwReset()     (pcsx2/pcsx2/IopHw.cpp)
  - psxBiosReset()   (pcsx2/pcsx2/ps2/Iop/PsxBios.cpp)
  - pgifInit()       (pcsx2/pcsx2/ps2/pgif.cpp)
  - Deci2Reset()     (pcsx2/pcsx2/R5900OpcodeImpl.cpp)

All output goes to runtime.log via BLogC (crash-safe, fsync after write).
"""

import sys

BIONIC_INCLUDE = '#include "BionicSX2Shared.h"'

# ── Helpers ────────────────────────────────────────────────────────────────

def ensure_include(path: str, mark: str):
    """Insert BIONIC_INCLUDE after the line containing *mark*."""
    with open(path) as f:
        lines = f.readlines()
    already = any(BIONIC_INCLUDE in l for l in lines)
    if already:
        return True
    out = []
    done = False
    for l in lines:
        out.append(l)
        if not done and mark in l:
            out.append(BIONIC_INCLUDE + "\n")
            done = True
    if not done:
        print(f"WARNING: {path} — marker '{mark}' not found for include insertion", file=sys.stderr)
        return False
    with open(path, "w") as f:
        f.writelines(out)
    return True

def patch_body(path: str, old_body: str, new_body: str, name: str):
    with open(path) as f:
        content = f.read()
    if old_body not in content:
        print(f"WARNING: {name} — function body not found in {path}", file=sys.stderr)
        idx = content.find(f"void {name}(" if "(" not in name.split("(")[0] else f"void {name}")
        if idx >= 0:
            print(f"  Found at offset {idx}:", file=sys.stderr)
            print(content[idx:idx+400], file=sys.stderr)
        return False
    content = content.replace(old_body, new_body, 1)
    with open(path, "w") as f:
        f.write(content)
    print(f"  {path}: patched {name}")
    return True


# ════════════════════════════════════════════════════════════════════════════
# 1.  R5900.cpp  —  cpuReset()   (17 markers)
# ════════════════════════════════════════════════════════════════════════════

R59_OLD = r"""void cpuReset()
{
	std::memset(&cpuRegs, 0, sizeof(cpuRegs));
	std::memset(&fpuRegs, 0, sizeof(fpuRegs));
	std::memset(&tlb, 0, sizeof(tlb));
	cachedTlbs.count = 0;

	cpuRegs.pc				= 0xbfc00000; //set pc reg to stack
	cpuRegs.CP0.n.Config	= 0x440;
	cpuRegs.CP0.n.Status.val= 0x70400004; //0x10900000 <-- wrong; // COP0 enabled | BEV = 1 | TS = 1
	cpuRegs.CP0.n.PRid		= 0x00002e20; // PRevID = Revision ID, same as R5900
	fpuRegs.fprc[0]			= 0x00002e30; // fpu Revision..
	fpuRegs.fprc[31]		= 0x01000001; // fpu Status/Control

	cpuRegs.nextEventCycle = cpuRegs.cycle + 4;
	EEsCycle = 0;
	EEoCycle = cpuRegs.cycle;

	psxReset();
	pgifInit();

	extern void Deci2Reset();		// lazy, no good header for it yet.
	Deci2Reset();

	AllowParams1 = !VMManager::Internal::IsFastBootInProgress();
	AllowParams2 = !VMManager::Internal::IsFastBootInProgress();
	ParamsRead = false;

	g_eeloadMain = 0;
	g_eeloadExec = 0;
	g_osdsys_str = 0;

	CBreakPoints::ClearSkipFirst();
}"""

R59_NEW = r"""void cpuReset()
{
	BLogC("[cpuReset] line 0: starting");
	std::memset(&cpuRegs, 0, sizeof(cpuRegs));
	BLogC("[cpuReset] line 1: memset cpuRegs done");
	std::memset(&fpuRegs, 0, sizeof(fpuRegs));
	BLogC("[cpuReset] line 2: memset fpuRegs done");
	std::memset(&tlb, 0, sizeof(tlb));
	BLogC("[cpuReset] line 3: memset tlb done");
	cachedTlbs.count = 0;
	BLogC("[cpuReset] line 4: cachedTlbs cleared");

	cpuRegs.pc				= 0xbfc00000; //set pc reg to stack
	BLogC("[cpuReset] line 5: pc set");
	cpuRegs.CP0.n.Config	= 0x440;
	BLogC("[cpuReset] line 6: Config set");
	cpuRegs.CP0.n.Status.val= 0x70400004; //0x10900000 <-- wrong; // COP0 enabled | BEV = 1 | TS = 1
	BLogC("[cpuReset] line 7: Status set");
	cpuRegs.CP0.n.PRid		= 0x00002e20; // PRevID = Revision ID, same as R5900
	BLogC("[cpuReset] line 8: PRid set");
	fpuRegs.fprc[0]			= 0x00002e30; // fpu Revision..
	fpuRegs.fprc[31]		= 0x01000001; // fpu Status/Control
	BLogC("[cpuReset] line 9: fprcs set");

	cpuRegs.nextEventCycle = cpuRegs.cycle + 4;
	BLogC("[cpuReset] line 10: nextEventCycle set");
	EEsCycle = 0;
	EEoCycle = cpuRegs.cycle;
	BLogC("[cpuReset] line 11: EEs/EEo set");

	psxReset();
	BLogC("[cpuReset] line 12: psxReset() done");
	pgifInit();
	BLogC("[cpuReset] line 13: pgifInit() done");

	extern void Deci2Reset();		// lazy, no good header for it yet.
	Deci2Reset();
	BLogC("[cpuReset] line 14: Deci2Reset() done");

	AllowParams1 = !VMManager::Internal::IsFastBootInProgress();
	AllowParams2 = !VMManager::Internal::IsFastBootInProgress();
	BLogC("[cpuReset] line 15: AllowParams set");
	ParamsRead = false;

	g_eeloadMain = 0;
	g_eeloadExec = 0;
	g_osdsys_str = 0;
	BLogC("[cpuReset] line 16: g_* globals zeroed");

	CBreakPoints::ClearSkipFirst();
	BLogC("[cpuReset] line 17: complete");
}"""


# ════════════════════════════════════════════════════════════════════════════
# 2.  R3000A.cpp  —  psxReset()   (6 markers)
# ════════════════════════════════════════════════════════════════════════════

R3K_OLD = r"""void psxReset()
{
	std::memset(&psxRegs, 0, sizeof(psxRegs));

	psxRegs.pc = 0xbfc00000; // Start in bootstrap
	psxRegs.CP0.n.Status = 0x00400000; // BEV = 1
	psxRegs.CP0.n.PRid   = 0x0000001f; // PRevID = Revision ID, same as the IOP R3000A

	psxRegs.iopBreak = 0;
	psxRegs.iopCycleEE = -1;
	psxRegs.iopCycleEECarry = 0;
	psxRegs.iopNextEventCycle = psxRegs.cycle + 4;

	psxHwReset();
	PSXCLK = 36864000;
	ioman::reset();
	psxBiosReset();
}"""

R3K_NEW = r"""void psxReset()
{
	BLogC("[psxReset] line 0: starting");
	std::memset(&psxRegs, 0, sizeof(psxRegs));
	BLogC("[psxReset] line 1: memset psxRegs done");

	psxRegs.pc = 0xbfc00000; // Start in bootstrap
	psxRegs.CP0.n.Status = 0x00400000; // BEV = 1
	psxRegs.CP0.n.PRid   = 0x0000001f; // PRevID = Revision ID, same as the IOP R3000A
	BLogC("[psxReset] line 2: regs set");

	psxRegs.iopBreak = 0;
	psxRegs.iopCycleEE = -1;
	psxRegs.iopCycleEECarry = 0;
	psxRegs.iopNextEventCycle = psxRegs.cycle + 4;
	BLogC("[psxReset] line 3: cycle regs set");

	psxHwReset();
	BLogC("[psxReset] line 4: psxHwReset() done");
	PSXCLK = 36864000;
	ioman::reset();
	BLogC("[psxReset] line 5: ioman::reset() done");
	psxBiosReset();
	BLogC("[psxReset] line 6: psxBiosReset() done");
}"""


# ════════════════════════════════════════════════════════════════════════════
# 3.  IopHw.cpp  —  psxHwReset()   (5 markers)
# ════════════════════════════════════════════════════════════════════════════

HW_OLD = r"""void psxHwReset() {
/*	if (Config.Sio) psxHu32(0x1070) |= 0x80;
	if (Config.SpuIrq) psxHu32(0x1070) |= 0x200;*/

	memset(iopHw, 0, 0x10000);

	mdecInit(); //initialize mdec decoder
	cdrReset();
	cdvdReset();
	psxRcntInit();
}"""

HW_NEW = r"""void psxHwReset() {
	BLogC("[psxHwReset] line 0: starting");
/*	if (Config.Sio) psxHu32(0x1070) |= 0x80;
	if (Config.SpuIrq) psxHu32(0x1070) |= 0x200;*/

	memset(iopHw, 0, 0x10000);
	BLogC("[psxHwReset] line 1: memset iopHw done");

	mdecInit(); //initialize mdec decoder
	BLogC("[psxHwReset] line 2: mdecInit() done");
	cdrReset();
	BLogC("[psxHwReset] line 3: cdrReset() done");
	cdvdReset();
	BLogC("[psxHwReset] line 4: cdvdReset() done");
	psxRcntInit();
	BLogC("[psxHwReset] line 5: psxRcntInit() done");
}"""


# ════════════════════════════════════════════════════════════════════════════
# 4.  PsxBios.cpp  —  psxBiosReset()   (2 markers)
# ════════════════════════════════════════════════════════════════════════════

BIOS_OLD = r"""void psxBiosReset()
{
    flush_stdout(true);
}"""

BIOS_NEW = r"""void psxBiosReset()
{
    BLogC("[psxBiosReset] line 0: starting");
    flush_stdout(true);
    BLogC("[psxBiosReset] line 1: flush_stdout done");
}"""


# ════════════════════════════════════════════════════════════════════════════
# 5.  pgif.cpp  —  pgifInit()   (2 markers)
# ════════════════════════════════════════════════════════════════════════════

PGIF_OLD = r"""void pgifInit()
{
	rb_gp1.buf = pgif_gp1_buffer;
	rb_gp1.size = PGIF_CMD_RB_SIZE;
	ringBufferClear(&rb_gp1);

	rb_gp0.buf = pgif_gp0_buffer;
	rb_gp0.size = PGIF_DAT_RB_SIZE;
	ringBufferClear(&rb_gp0);

	pgpu.stat.write(0);
	pgif.ctrl.write(0);
	old_gp0_value = 0;


	dmaRegs.madr.address = 0;
	dmaRegs.bcr.write(0);
	dmaRegs.chcr.write(0);
	//pgpuDmaTadr = 0;

	dma.state.ll_active = 0;
	dma.state.to_gpu_active = 0;
	dma.state.to_iop_active = 0;

	dma.ll_dma.data_read_address = 0;
	dma.ll_dma.current_word = 0;
	dma.ll_dma.total_words = 0;
	dma.ll_dma.next_address = 0;

	dma.normal.total_words = 0;
	dma.normal.current_word = 0;
	dma.normal.address = 0;
}"""

PGIF_NEW = r"""void pgifInit()
{
	BLogC("[pgifInit] line 0: starting");
	rb_gp1.buf = pgif_gp1_buffer;
	rb_gp1.size = PGIF_CMD_RB_SIZE;
	ringBufferClear(&rb_gp1);
	BLogC("[pgifInit] line 1: rb_gp1 cleared");

	rb_gp0.buf = pgif_gp0_buffer;
	rb_gp0.size = PGIF_DAT_RB_SIZE;
	ringBufferClear(&rb_gp0);
	BLogC("[pgifInit] line 2: rb_gp0 cleared");

	pgpu.stat.write(0);
	pgif.ctrl.write(0);
	old_gp0_value = 0;
	BLogC("[pgifInit] line 3: pgpu/pgif regs zeroed");

	dmaRegs.madr.address = 0;
	dmaRegs.bcr.write(0);
	dmaRegs.chcr.write(0);
	//pgpuDmaTadr = 0;
	BLogC("[pgifInit] line 4: dmaRegs zeroed");

	dma.state.ll_active = 0;
	dma.state.to_gpu_active = 0;
	dma.state.to_iop_active = 0;
	BLogC("[pgifInit] line 5: dma states zeroed");

	dma.ll_dma.data_read_address = 0;
	dma.ll_dma.current_word = 0;
	dma.ll_dma.total_words = 0;
	dma.ll_dma.next_address = 0;
	BLogC("[pgifInit] line 6: dma ll_dma zeroed");

	dma.normal.total_words = 0;
	dma.normal.current_word = 0;
	dma.normal.address = 0;
	BLogC("[pgifInit] line 7: dma normal zeroed");
}"""


# ════════════════════════════════════════════════════════════════════════════
# 6.  R5900OpcodeImpl.cpp  —  Deci2Reset()   (2 markers)
# ════════════════════════════════════════════════════════════════════════════

DECI2_OLD = r"""void Deci2Reset()
{
	deci2handler	= 0;
	deci2addr		= 0;
	std::memset(deci2buffer, 0, sizeof(deci2buffer));
}"""

DECI2_NEW = r"""void Deci2Reset()
{
	BLogC("[Deci2Reset] line 0: starting");
	deci2handler	= 0;
	deci2addr		= 0;
	BLogC("[Deci2Reset] line 1: handler/addr zeroed");
	std::memset(deci2buffer, 0, sizeof(deci2buffer));
	BLogC("[Deci2Reset] line 2: buffer zeroed");
}"""


# ════════════════════════════════════════════════════════════════════════════
# Main
# ════════════════════════════════════════════════════════════════════════════

def main():
    ok = True

    # File paths (relative to repo root, matching CI working-dir)
    files = [
        ("pcsx2/pcsx2/R5900.cpp",        R59_OLD,    R59_NEW,    "cpuReset",      '#include "R5900.h"'),
        ("pcsx2/pcsx2/R3000A.cpp",       R3K_OLD,    R3K_NEW,    "psxReset",      '#include "CDVD/CDVD.h"'),
        ("pcsx2/pcsx2/IopHw.cpp",        HW_OLD,     HW_NEW,     "psxHwReset",    '#include "R3000A.h"'),
        ("pcsx2/pcsx2/ps2/Iop/PsxBios.cpp",  BIOS_OLD,  BIOS_NEW, "psxBiosReset",  '#include "fmt/format.h"'),
        ("pcsx2/pcsx2/ps2/pgif.cpp",     PGIF_OLD,   PGIF_NEW,   "pgifInit",      '#include "Common.h"'),
        ("pcsx2/pcsx2/R5900OpcodeImpl.cpp", DECI2_OLD, DECI2_NEW, "Deci2Reset",   '#include "VMManager.h"'),
    ]

    for path, old, new_, name, include_mark in files:
        # Ensure the BionicSX2Shared.h include is present
        if not ensure_include(path, include_mark):
            ok = False
        # Patch the function body
        if not patch_body(path, old, new_, name):
            ok = False

    if ok:
        print("=== All patches applied successfully ===")
    else:
        print("=== Some patches FAILED ===", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
