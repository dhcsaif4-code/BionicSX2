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

// =====================================================================
// libjpeg stubs (ios-deps does not include libjpeg-turbo for bringup)
// =====================================================================
#include <csetjmp>
struct jpeg_error_mgr;
struct jpeg_compress_struct;
struct jpeg_decompress_struct;

extern "C" void jpeg_std_error(jpeg_error_mgr*) {}
extern "C" void jpeg_create_compress(jpeg_compress_struct*, int, size_t) {}
extern "C" void jpeg_create_decompress(jpeg_decompress_struct*, int, size_t) {}
extern "C" void jpeg_set_defaults(jpeg_compress_struct*) {}
extern "C" void jpeg_set_quality(jpeg_compress_struct*, int, int) {}
extern "C" void jpeg_start_compress(jpeg_compress_struct*, int) {}
extern "C" int jpeg_write_scanlines(jpeg_compress_struct*, unsigned char**, int) { return 0; }
extern "C" void jpeg_finish_compress(jpeg_compress_struct*) {}
extern "C" void jpeg_destroy_compress(jpeg_compress_struct*) {}
extern "C" int jpeg_read_header(jpeg_decompress_struct*, int) { return 0; }
extern "C" int jpeg_start_decompress(jpeg_decompress_struct*) { return 0; }
extern "C" int jpeg_read_scanlines(jpeg_decompress_struct*, unsigned char**, int) { return 0; }
extern "C" void jpeg_finish_decompress(jpeg_decompress_struct*) {}
extern "C" void jpeg_destroy_decompress(jpeg_decompress_struct*) {}
extern "C" void jpeg_mem_src(jpeg_decompress_struct*, const unsigned char*, unsigned long) {}

// =====================================================================
// plutovg stubs (not in ios-deps for bringup)
// =====================================================================
struct plutovg_surface_t;
struct plutovg_canvas_t;
extern "C" plutovg_surface_t* plutovg_surface_create_for_data(unsigned char*, int, int, int) { return nullptr; }
extern "C" void plutovg_surface_destroy(plutovg_surface_t*) {}
extern "C" plutovg_canvas_t* plutovg_canvas_create(plutovg_surface_t*) { return nullptr; }
extern "C" void plutovg_canvas_destroy(plutovg_canvas_t*) {}
extern "C" void plutovg_canvas_scale(plutovg_canvas_t*, double, double) {}
extern "C" void plutovg_canvas_translate(plutovg_canvas_t*, double, double) {}
extern "C" void plutovg_convert_argb_to_rgba(unsigned char*, const unsigned char*, int, int, int) {}

// =====================================================================
// plutosvg stubs (not in ios-deps for bringup)
// =====================================================================
struct plutosvg_document_t;
struct plutovg_surface_t;
extern "C" plutosvg_document_t* plutosvg_document_load_from_data(const char*, size_t, float, float, float, plutovg_surface_t*) { return nullptr; }
extern "C" float plutosvg_document_get_width(plutosvg_document_t*) { return 0.0f; }
extern "C" float plutosvg_document_get_height(plutosvg_document_t*) { return 0.0f; }
extern "C" int plutosvg_document_render(plutosvg_document_t*, void*, plutovg_canvas_t*, void*, void*, void*) { return 0; }
extern "C" void plutosvg_document_destroy(plutosvg_document_t*) {}
