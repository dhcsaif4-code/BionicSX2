#!/usr/bin/env python3
"""Apply per-line fprintf debug tracing to cpuReset() and psxReset()."""

import sys

# ── R5900.cpp: cpuReset() — 17 per-line traces ───────────────────────────────

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
	fprintf(stderr, "[cpuReset] line 0: starting\n"); fflush(stderr);
	std::memset(&cpuRegs, 0, sizeof(cpuRegs));
	fprintf(stderr, "[cpuReset] line 1: memset cpuRegs done\n"); fflush(stderr);
	std::memset(&fpuRegs, 0, sizeof(fpuRegs));
	fprintf(stderr, "[cpuReset] line 2: memset fpuRegs done\n"); fflush(stderr);
	std::memset(&tlb, 0, sizeof(tlb));
	fprintf(stderr, "[cpuReset] line 3: memset tlb done\n"); fflush(stderr);
	cachedTlbs.count = 0;
	fprintf(stderr, "[cpuReset] line 4: cachedTlbs cleared\n"); fflush(stderr);

	cpuRegs.pc				= 0xbfc00000; //set pc reg to stack
	fprintf(stderr, "[cpuReset] line 5: pc set\n"); fflush(stderr);
	cpuRegs.CP0.n.Config	= 0x440;
	fprintf(stderr, "[cpuReset] line 6: Config set\n"); fflush(stderr);
	cpuRegs.CP0.n.Status.val= 0x70400004; //0x10900000 <-- wrong; // COP0 enabled | BEV = 1 | TS = 1
	fprintf(stderr, "[cpuReset] line 7: Status set\n"); fflush(stderr);
	cpuRegs.CP0.n.PRid		= 0x00002e20; // PRevID = Revision ID, same as R5900
	fprintf(stderr, "[cpuReset] line 8: PRid set\n"); fflush(stderr);
	fpuRegs.fprc[0]			= 0x00002e30; // fpu Revision..
	fpuRegs.fprc[31]		= 0x01000001; // fpu Status/Control
	fprintf(stderr, "[cpuReset] line 9: fprcs set\n"); fflush(stderr);

	cpuRegs.nextEventCycle = cpuRegs.cycle + 4;
	fprintf(stderr, "[cpuReset] line 10: nextEventCycle set\n"); fflush(stderr);
	EEsCycle = 0;
	EEoCycle = cpuRegs.cycle;
	fprintf(stderr, "[cpuReset] line 11: EEs/EEo set\n"); fflush(stderr);

	psxReset();
	fprintf(stderr, "[cpuReset] line 12: psxReset() done\n"); fflush(stderr);
	pgifInit();
	fprintf(stderr, "[cpuReset] line 13: pgifInit() done\n"); fflush(stderr);

	extern void Deci2Reset();		// lazy, no good header for it yet.
	Deci2Reset();
	fprintf(stderr, "[cpuReset] line 14: Deci2Reset() done\n"); fflush(stderr);

	AllowParams1 = !VMManager::Internal::IsFastBootInProgress();
	AllowParams2 = !VMManager::Internal::IsFastBootInProgress();
	fprintf(stderr, "[cpuReset] line 15: AllowParams set\n"); fflush(stderr);
	ParamsRead = false;

	g_eeloadMain = 0;
	g_eeloadExec = 0;
	g_osdsys_str = 0;
	fprintf(stderr, "[cpuReset] line 16: g_* globals zeroed\n"); fflush(stderr);

	CBreakPoints::ClearSkipFirst();
	fprintf(stderr, "[cpuReset] line 17: complete\n"); fflush(stderr);
}"""

# ── R3000A.cpp: psxReset() — 6 per-line traces ──────────────────────────────

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
	fprintf(stderr, "[psxReset] line 0: starting\n"); fflush(stderr);
	std::memset(&psxRegs, 0, sizeof(psxRegs));
	fprintf(stderr, "[psxReset] line 1: memset psxRegs done\n"); fflush(stderr);

	psxRegs.pc = 0xbfc00000; // Start in bootstrap
	psxRegs.CP0.n.Status = 0x00400000; // BEV = 1
	psxRegs.CP0.n.PRid   = 0x0000001f; // PRevID = Revision ID, same as the IOP R3000A
	fprintf(stderr, "[psxReset] line 2: regs set\n"); fflush(stderr);

	psxRegs.iopBreak = 0;
	psxRegs.iopCycleEE = -1;
	psxRegs.iopCycleEECarry = 0;
	psxRegs.iopNextEventCycle = psxRegs.cycle + 4;
	fprintf(stderr, "[psxReset] line 3: cycle regs set\n"); fflush(stderr);

	psxHwReset();
	fprintf(stderr, "[psxReset] line 4: psxHwReset() done\n"); fflush(stderr);
	PSXCLK = 36864000;
	ioman::reset();
	fprintf(stderr, "[psxReset] line 5: ioman::reset() done\n"); fflush(stderr);
	psxBiosReset();
	fprintf(stderr, "[psxReset] line 6: psxBiosReset() done\n"); fflush(stderr);
}"""


def patch_file(path, old, new, name):
    with open(path, "r") as f:
        content = f.read()

    if old not in content:
        print(f"WARNING: {name} — body not found as expected")
        idx = content.find(f"void {name}")
        if idx >= 0:
            print(f"Found at offset {idx}:")
            print(content[idx:idx+600])
        return False

    content = content.replace(old, new, 1)
    with open(path, "w") as f:
        f.write(content)
    print(f"{path}: patched with per-line {name} tracing")
    return True


def main():
    ok = True
    ok &= patch_file("pcsx2/pcsx2/R5900.cpp", R59_OLD, R59_NEW, "cpuReset")
    ok &= patch_file("pcsx2/pcsx2/R3000A.cpp", R3K_OLD, R3K_NEW, "psxReset")

    if ok:
        print("=== All patches applied successfully ===")
    else:
        print("=== Some patches FAILED ===", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
