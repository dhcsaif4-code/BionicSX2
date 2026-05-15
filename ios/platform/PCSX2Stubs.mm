// AUDIT REFERENCE: Phase 0 (Categories 1–9)
// STATUS: NEW
// NOTE: Minimal stubs — avoid including PCSX2 headers to prevent
// declaration conflicts. Uses forward declarations where possible.
#include "common/Pcsx2Types.h"
#include <memory>

// AUDIT: VifUnpackSSE_Init forced no-op for iOS (Phase 0-B)
extern "C" void VifUnpackSSE_Init() {}
extern "C" void vtlb_DynBackpatchLoadStore(uptr, u32, u32, u32, u8, u8, u8, bool, bool, bool) {}

// Category 8: DEV9 stubs
extern "C" void smap_async(void*, int) {}
extern "C" u32 smap_read8(u32 a) { return 0; }
extern "C" u32 smap_read16(u32 a) { return 0; }
extern "C" u32 smap_read32(u32 a) { return 0; }
extern "C" void smap_write8(u32, u32) {}
extern "C" void smap_write16(u32, u32) {}
extern "C" void smap_write32(u32, u32) {}
extern "C" void smap_readDMA8Mem(u32, u32) {}
extern "C" void smap_writeDMA8Mem(u32, u32) {}
extern "C" u32 FLASHread32(u32 a) { return 0; }
extern "C" void FLASHwrite32(u32, u32) {}
extern "C" void FLASHinit() {}
extern "C" void InitNet() {}
extern "C" void TermNet() {}
extern "C" void ReconfigureLiveNet() {}

// USB stubs
extern "C" u32 usb_read8(u32 a) { return 0; }
extern "C" u32 usb_read16(u32 a) { return 0; }
extern "C" u32 usb_read32(u32 a) { return 0; }
extern "C" void usb_write8(u32, u32) {}
extern "C" void usb_write16(u32, u32) {}
extern "C" void usb_write32(u32, u32) {}
extern "C" const char* usb_desc_parse(const u8* data, int len, const char* cb, void* opaque, int* r) { return nullptr; }

// PGIF stubs
extern "C" void PGIFrQword(u32, u32) {}
extern "C" void PGIFwQword(u32, u32) {}
extern "C" u32 PGIFr(u32 a) { return 0; }
extern "C" u32 PGIFw(u32 a, u32 v) { return 0; }
extern "C" void pgifInit() {}

// FIFO stubs
extern "C" void ReadFifoSingleWord(void*, void*) {}
extern "C" void ReadFIFO_VIF1(void*, void*) {}
extern "C" void WriteFIFO_VIF0(void*, void*) {}
extern "C" void WriteFIFO_VIF1(void*, void*) {}
extern "C" void WriteFIFO_GIF(void*, void*) {}
extern "C" void sifReset() {}
extern "C" void SIF1Dma() {}
extern "C" void dmaSIF1() {}
extern "C" void dmaSIF2() {}
extern "C" void EEsif1Interrupt() {}
extern "C" void sif1Interrupt() {}
extern "C" void sif2Interrupt() {}
extern "C" void dVifRelease(int) {}
extern "C" void dVifReset(int) {}

// CDR stubs
extern "C" u32 cdrRead0(u32 a) { return 0; }
extern "C" u32 cdrRead1(u32 a) { return 0; }
extern "C" u32 cdrRead2(u32 a) { return 0; }
extern "C" u32 cdrRead3(u32 a) { return 0; }
extern "C" void cdrWrite0(u32, u32) {}
extern "C" void cdrWrite1(u32, u32) {}
extern "C" void cdrWrite2(u32, u32) {}
extern "C" void cdrWrite3(u32, u32) {}
extern "C" void cdrReset() {}
extern "C" void cdrInterrupt() {}
extern "C" void cdrReadInterrupt() {}

// IPU stubs
extern "C" u32 ipuRead32(u32 a) { return 0; }
extern "C" u64 ipuRead64(u32 a) { return 0; }
extern "C" void ipuWrite32(u32, u32) {}
extern "C" void ipuWrite64(u32, u64) {}
extern "C" void ipuReset() {}
extern "C" void ipu0Interrupt() {}
extern "C" void ipu1Interrupt() {}
extern "C" void ipuCMDProcess(int, u32) {}
extern "C" void dmaIPU0() {}
extern "C" void dmaIPU1() {}
extern "C" void ReadFIFO_IPUout(void*, void*) {}
extern "C" void WriteFIFO_IPUin(void*, void*) {}

// MDEC stubs
extern "C" u32 mdecRead0(u32 a) { return 0; }
extern "C" u32 mdecRead1(u32 a) { return 0; }
extern "C" void mdecWrite0(u32, u32) {}
extern "C" void mdecWrite1(u32, u32) {}
extern "C" void mdecInit() {}

// Cache stubs
extern "C" void readCache8(u32, u32*) {}
extern "C" void readCache16(u32, u32*) {}
extern "C" void readCache32(u32, u32*) {}
extern "C" void readCache64(u32, u32*) {}
extern "C" void readCache128(u32, u32*) {}
extern "C" void writeCache8(u32, u32) {}
extern "C" void writeCache16(u32, u32) {}
extern "C" void writeCache32(u32, u32) {}
extern "C" void writeCache64(u32, u64) {}
extern "C" void writeCache128(u32, u128) {}
extern "C" void writebackCache(u32, u32) {}

// BIOS
extern "C" void CopyBIOSToMemory() {}

// Misc extern stubs
extern "C" void GSVertexSW_InitStatic() {}
extern "C" void ReadOSDConfigParames() {}
extern "C" void GSDumpReplayer_IsReplaying() {}
extern "C" void GSDumpReplayer_LoadDump() {}
