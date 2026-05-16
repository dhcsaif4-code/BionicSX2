// AUDIT REFERENCE: Phase 0 (Categories 1–9)
// STATUS: NEW
// NOTE: Minimal stubs — avoid including PCSX2 headers to prevent
// declaration conflicts. Uses forward declarations where possible.
#include "common/Pcsx2Types.h"
#include "common/Threading.h"
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

// Discord RPC stubs
extern "C" void Discord_Initialize(const char*, void*, int, const char*) {}
extern "C" void Discord_Shutdown() {}
extern "C" void Discord_RunCallbacks() {}
extern "C" void Discord_UpdatePresence(const void*) {}
extern "C" void Discord_ClearPresence() {}

// Additional DEV9 stubs
extern "C" void DEV9read16() {}
extern "C" void DEV9read32() {}
extern "C" void DEV9write8() {}
extern "C" void DEV9write16() {}
extern "C" void DEV9write32() {}
extern "C" void DEV9readDMA8Mem() {}
extern "C" void DEV9irqHandler() {}
extern "C" void DEV9shutdown() {}

// Additional USB stubs
extern "C" void USBwrite16() {}
extern "C" void USBwrite32() {}
extern "C" void USBshutdown() {}

// VIF JIT stubs — interpreter path only (Phase 0-C)
extern "C" void dVifUnpack_0() {}
extern "C" void dVifUnpack_1() {}

// Aligned memory (Darwin uses posix_memalign)
#include <stdlib.h>
extern "C" void* _aligned_malloc(size_t size, size_t align) {
    void* ptr = nullptr;
    posix_memalign(&ptr, align, size);
    return ptr;
}
extern "C" void _aligned_free(void* ptr) { free(ptr); }

// libzip stubs — excluded from iOS bringup build
extern "C" {
  void* zip_open(const char*, int, int*) { return nullptr; }
  void* zip_open_from_source(void*, int, void*) { return nullptr; }
  int   zip_close(void*) { return -1; }
  const char* zip_strerror(void*) { return "stubbed"; }
  int   zip_name_locate(void*, const char*, int) { return -1; }
  void* zip_fopen_index(void*, int, int) { return nullptr; }
  int   zip_fclose(void*) { return -1; }
  long  zip_fread(void*, void*, size_t) { return -1; }
  int   zip_stat_index(void*, int, int, void*) { return -1; }
  int   zip_add(void*, const char*, void*) { return -1; }
  int   zip_file_add(void*, const char*, void*, int) { return -1; }
  int   zip_set_file_compression(void*, int, int, int) { return -1; }
  void* zip_source_buffer(void*, const void*, size_t, int) { return nullptr; }
  void* zip_source_buffer_create(const void*, size_t, int, void*) { return nullptr; }
  void* zip_source_file_create(const char*, int, int, void*) { return nullptr; }
  int   zip_source_free(void*) { return -1; }
  int   zip_source_begin_write(void*) { return -1; }
  int   zip_source_commit_write(void*) { return -1; }
  int   zip_source_write(void*, const void*, size_t) { return -1; }
}

// Misc
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
// USB subsystem stubs — iOS bringup (Audit Sec 1.2, Phase 0-F)
// =====================================================================
extern "C" void USBclose() {}
extern "C" void USBopen() {}
extern "C" u32 USBread(u32 a, u32 v) { return 0; }
extern "C" void USBwrite(u32 a, u32 v) {}
extern "C" void USBirqHandler(int a) {}
extern "C" void USBfreeze(int a) {}
extern "C" void USBasync(int a) {}

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

// =====================================================================
// cubeb stubs (cannot build for iOS — macOS-only CoreAudio)
// =====================================================================
extern "C" {
  int cubeb_init(void** ctx, const char* name, const char* backend) { *ctx = nullptr; return 0; }
  void cubeb_destroy(void* ctx) {}
  int cubeb_stream_init(void* ctx, void** stm, const char* name, void* in, void* in_params, void* out, void* out_params, unsigned int latency, void* cb, void* state_cb, void* user) { *stm = nullptr; return 0; }
  void cubeb_stream_destroy(void* stm) {}
  int cubeb_stream_start(void* stm) { return 0; }
  int cubeb_stream_stop(void* stm) { return 0; }
  int cubeb_stream_get_latency(void* stm, unsigned int* latency) { *latency = 0; return 0; }
  int cubeb_stream_set_volume(void* stm, float volume) { return 0; }
  const char* cubeb_get_backend_id(void* ctx) { return "ios-stub"; }
  int cubeb_get_max_channel_count(void* ctx, unsigned int* max) { *max = 2; return 0; }
  int cubeb_get_min_latency(void* ctx, void* params, unsigned int* latency) { *latency = 256; return 0; }
  int cubeb_get_preferred_sample_rate(void* ctx, unsigned int* rate) { *rate = 44100; return 0; }
}

// =====================================================================
// LZMA/7-Zip stubs (ios-deps builds lzma but PCSX2 uses 7z directly)
// =====================================================================
extern "C" void CrcGenerateTable(void) {}
extern "C" void Crc64GenerateTable(void) {}
extern "C" void LookToRead2_CreateVTable(void*, int) {}
extern "C" void XzProps_Init(void*) {}
extern "C" int XzUnpacker_Code(void*, uint8_t*, size_t*, const uint8_t*, size_t*, int, int, void*) { return 0; }
extern "C" void XzUnpacker_Construct(void*, void*) {}
extern "C" void XzUnpacker_Free(void*) {}
extern "C" void XzUnpacker_Init(void*, int) {}
extern "C" void XzUnpacker_PrepareToRandomBlockDecoding(void*) {}
extern "C" void XzUnpacker_SetOutBuf(void*, uint8_t*, size_t) {}
extern "C" int Xz_Encode(void*, void*, void*, void*) { return 0; }
extern "C" void Xzs_Construct(void*) {}
extern "C" void Xzs_Free(void*, void*) {}
extern "C" uint64_t Xzs_GetNumBlocks(void*) { return 0; }
extern "C" int Xzs_ReadBackward(void*, void*, int64_t*, void*, void*) { return 0; }

// =====================================================================
// BC texture decompression stubs (not needed for Metal renderer bringup)
// =====================================================================
extern "C" void DecompressBlockBC1(const uint8_t*, uint32_t*, uint32_t) {}
extern "C" void DecompressBlockBC2(const uint8_t*, uint32_t*, uint32_t) {}
extern "C" void DecompressBlockBC3(const uint8_t*, uint32_t*, uint32_t) {}
extern "C" void bc7decomp_unpack_bc7(const uint8_t*, uint32_t*) {}

// =====================================================================
// DynamicLibrary stubs (no dlopen on unsigned iOS)
// =====================================================================
namespace Common {
  struct DynamicLibrary {
    static void* Open(const char*, std::string*) { return nullptr; }
    static void Close(void*) {}
    static void* GetSymbolAddress(void*, const char*) { return nullptr; }
  };
}

// =====================================================================
// Log stubs — Log.cpp does not exist in the repo
// =====================================================================
#include <fmt/core.h>
namespace Log {
  void Write(const char*, const char*,
             const char*, const char*) {}
  void WriteFmtArgs(const char*, const char*,
                    const char*, fmt::string_view,
                    fmt::format_args) {}
}

// =====================================================================
// Threading stubs — Threading.cpp does not exist in the repo
// =====================================================================
namespace Threading {
  void WorkSema::WaitForWork() {}
  bool WorkSema::WaitForEmpty() { return true; }
}

// =====================================================================
// ImGuiFreeType stubs — imgui_freetype.cpp does not exist in the repo
// =====================================================================
struct ImFontBuilderIO;
namespace ImGuiFreeType {
  const ImFontBuilderIO* GetFontLoader() { return nullptr; }
}

// =====================================================================
// Misc stubs
// =====================================================================
extern "C" void pxOnAssertFail(const char*, int, const char*, const char*) {}
extern "C" void ShortSpin() {}
extern "C" void GetValidDrive() {}
extern "C" void* GetMetalAdapterList() { return nullptr; }
extern "C" void* GetOpticalDriveList() { return nullptr; }
