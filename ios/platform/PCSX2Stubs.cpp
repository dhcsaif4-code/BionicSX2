#include <TargetConditionals.h>
#include "common/Pcsx2Types.h"
#include "common/Threading.h"
#include <memory>
#include <stdlib.h>
#include <fmt/core.h>
#include <string>
#include <vector>
#include <libkern/OSCacheControl.h>

// =====================================================================
// All C-linkage stubs in one extern "C" block
// =====================================================================
extern "C" {

// g_Alloc/g_Free (7-zip/LZMA)
void* (*g_Alloc)(size_t) = malloc;
void (*g_Free)(void*) = free;

// DEV9
void DEV9init() {}
void DEV9open() {}
void DEV9close() {}
void DEV9shutdown() {}
void DEV9async(unsigned int) {}
void DEV9irqHandler() {}
void DEV9CheckChanges(const void*) {}
unsigned char  DEV9read8(unsigned int) { return 0; }
unsigned short DEV9read16(unsigned int) { return 0; }
unsigned int   DEV9read32(unsigned int) { return 0; }
void DEV9write8(unsigned int, unsigned char) {}
void DEV9write16(unsigned int, unsigned short) {}
void DEV9write32(unsigned int, unsigned int) {}
void DEV9readDMA8Mem(unsigned int*, int) {}
void DEV9writeDMA8Mem(unsigned int*, int) {}

void smap_async(void*, int) {}
u32 smap_read8(u32 a) { return 0; }
u32 smap_read16(u32 a) { return 0; }
u32 smap_read32(u32 a) { return 0; }
void smap_write8(u32, u32) {}
void smap_write16(u32, u32) {}
void smap_write32(u32, u32) {}
void smap_readDMA8Mem(u32, u32) {}
void smap_writeDMA8Mem(u32, u32) {}
u32 FLASHread32(u32 a) { return 0; }
void FLASHwrite32(u32, u32) {}
void FLASHinit() {}
void InitNet() {}
void TermNet() {}
void ReconfigureLiveNet() {}

// USB
void USBinit() {}
void USBopen() {}
void USBclose() {}
void USBshutdown() {}
void USBreset() {}
void USBasync(unsigned int) {}
unsigned char  USBread8(unsigned int) { return 0; }
unsigned short USBread16(unsigned int) { return 0; }
unsigned int   USBread32(unsigned int) { return 0; }
void USBwrite8(unsigned int, unsigned char) {}
void USBwrite16(unsigned int, unsigned short) {}
void USBwrite32(unsigned int, unsigned int) {}

u32 usb_read8(u32 a) { return 0; }
u32 usb_read16(u32 a) { return 0; }
u32 usb_read32(u32 a) { return 0; }
void usb_write8(u32, u32) {}
void usb_write16(u32, u32) {}
void usb_write32(u32, u32) {}
const char* usb_desc_parse(const u8* data, int len, const char* cb, void* opaque, int* r) { return nullptr; }
void USBirqHandler(int a) {}
void USBfreeze(int a) {}
u32 USBread(u32 a, u32 v) { return 0; }
void USBwrite(u32 a, u32 v) {}

// PGIF
void PGIFrQword(u32, u32) {}
void PGIFwQword(u32, u32) {}
u32 PGIFr(u32 a) { return 0; }
u32 PGIFw(u32 a, u32 v) { return 0; }
void pgifInit() {}

// SIF / FIFO
void ReadFifoSingleWord(void*, void*) {}
void ReadFIFO_VIF1(void*, void*) {}
void WriteFIFO_VIF0(void*, void*) {}
void WriteFIFO_VIF1(void*, void*) {}
void WriteFIFO_GIF(void*, void*) {}
void sifReset() {}
void SIF1Dma() {}
void dmaSIF1() {}
void dmaSIF2() {}
void EEsif1Interrupt() {}
void sif1Interrupt() {}
void sif2Interrupt() {}

// CDR
u32 cdrRead0(u32 a) { return 0; }
u32 cdrRead1(u32 a) { return 0; }
u32 cdrRead2(u32 a) { return 0; }
u32 cdrRead3(u32 a) { return 0; }
void cdrWrite0(u32, u32) {}
void cdrWrite1(u32, u32) {}
void cdrWrite2(u32, u32) {}
void cdrWrite3(u32, u32) {}
void cdrReset() {}
void cdrInterrupt() {}
void cdrReadInterrupt() {}

// IPU
u32 ipuRead32(u32 a) { return 0; }
u64 ipuRead64(u32 a) { return 0; }
void ipuWrite32(u32, u32) {}
void ipuWrite64(u32, u64) {}
void ipuReset() {}
void ipu0Interrupt() {}
void ipu1Interrupt() {}
void ipuCMDProcess(int, u32) {}
void dmaIPU0() {}
void dmaIPU1() {}
void ReadFIFO_IPUout(void*, void*) {}
void WriteFIFO_IPUin(void*, void*) {}

// MDEC
u32 mdecRead0(u32 a) { return 0; }
u32 mdecRead1(u32 a) { return 0; }
void mdecWrite0(u32, u32) {}
void mdecWrite1(u32, u32) {}
void mdecInit() {}

// Cache
void readCache8(u32, u32*) {}
void readCache16(u32, u32*) {}
void readCache32(u32, u32*) {}
void readCache64(u32, u32*) {}
void readCache128(u32, u32*) {}
void writeCache8(u32, u32) {}
void writeCache16(u32, u32) {}
void writeCache32(u32, u32) {}
void writeCache64(u32, u64) {}
void writeCache128(u32, u128) {}
void writebackCache(u32, u32) {}

// BIOS
void CopyBIOSToMemory() {}

// VIF
void VifUnpackSSE_Init() {}
void vtlb_DynBackpatchLoadStore(unsigned long, unsigned int, unsigned int,
  unsigned int, unsigned int, unsigned int, unsigned char,
  unsigned char, unsigned char, bool, bool, bool) {}
void dVifRelease(int) {}
void dVifReset(int) {}
void dVifUnpack_0(const unsigned char*, bool) {}
void dVifUnpack_1(const unsigned char*, bool) {}

// Discord
void Discord_Initialize(const char*, void*, int, const char*) {}
void Discord_Shutdown() {}
void Discord_RunCallbacks() {}
void Discord_UpdatePresence(const void*) {}
void Discord_ClearPresence() {}

// Misc
void pxOnAssertFail(const char* msg, int line, const char* file, const char* func) {
  NSLog(@"[BionicSX2] Assert: %s:%d %s — %s", file, line, func, msg);
  abort();
}
void ShortSpin() {}
void GetValidDrive(void*) {}
void* GetMetalAdapterList() { return nullptr; }
void* GetOpticalDriveList() { return nullptr; }

void GSVertexSW_InitStatic() {}
void ReadOSDConfigParames() {}
void GSDumpReplayer_IsReplaying() {}
void GSDumpReplayer_LoadDump() {}

void* _aligned_malloc(unsigned long size, unsigned long align) {
  void* ptr = nullptr;
  posix_memalign(&ptr, align < sizeof(void*) ? sizeof(void*) : align, size);
  return ptr;
}
void _aligned_free(void* ptr) { free(ptr); }

// BC decompression
void DecompressBlockBC1(unsigned int, unsigned int, unsigned int, const unsigned char*, unsigned char*) {}
void DecompressBlockBC2(unsigned int, unsigned int, unsigned int, const unsigned char*, unsigned char*) {}
void DecompressBlockBC3(unsigned int, unsigned int, unsigned int, const unsigned char*, unsigned char*) {}
void bc7decomp_unpack_bc7(const uint8_t*, uint32_t*) {}

// __clear_cache — compiler runtime for ARM64; needed when __builtin___clear_cache is used
extern "C" void __clear_cache(char* begin, char* end) {
  sys_icache_invalidate(begin, (size_t)(end - begin));
}

// libzip
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
void  zip_discard(void*) {}
void* zip_fopen(void*, const char*, int) { return nullptr; }
const char* zip_error_strerror(void*) { return "stub"; }
int   zip_error_code_zip(void*) { return -1; }

// jpeg
void jpeg_std_error(struct jpeg_error_mgr*) {}
void jpeg_create_compress(struct jpeg_compress_struct*, int, size_t) {}
void jpeg_create_decompress(struct jpeg_decompress_struct*, int, size_t) {}
void jpeg_set_defaults(struct jpeg_compress_struct*) {}
void jpeg_set_quality(struct jpeg_compress_struct*, int, int) {}
void jpeg_start_compress(struct jpeg_compress_struct*, int) {}
int jpeg_write_scanlines(struct jpeg_compress_struct*, unsigned char**, int) { return 0; }
void jpeg_finish_compress(struct jpeg_compress_struct*) {}
void jpeg_destroy_compress(struct jpeg_compress_struct*) {}
int jpeg_read_header(struct jpeg_decompress_struct*, int) { return 0; }
int jpeg_start_decompress(struct jpeg_decompress_struct*) { return 0; }
int jpeg_read_scanlines(struct jpeg_decompress_struct*, unsigned char**, int) { return 0; }
void jpeg_finish_decompress(struct jpeg_decompress_struct*) {}
void jpeg_destroy_decompress(struct jpeg_decompress_struct*) {}
void jpeg_mem_src(struct jpeg_decompress_struct*, const unsigned char*, unsigned long) {}

// plutovg
struct plutovg_surface_t;
struct plutovg_canvas_t;
plutovg_surface_t* plutovg_surface_create_for_data(unsigned char*, int, int, int) { return nullptr; }
void plutovg_surface_destroy(plutovg_surface_t*) {}
plutovg_canvas_t* plutovg_canvas_create(plutovg_surface_t*) { return nullptr; }
void plutovg_canvas_destroy(plutovg_canvas_t*) {}
void plutovg_canvas_scale(plutovg_canvas_t*, double, double) {}
void plutovg_canvas_translate(plutovg_canvas_t*, double, double) {}
void plutovg_convert_argb_to_rgba(unsigned char*, const unsigned char*, int, int, int) {}

// plutosvg — stubs now inline in generated/plutosvg.h

// cubeb
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

// LZMA/7-Zip
void CrcGenerateTable(void) {}
void Crc64GenerateTable(void) {}
void LookToRead2_CreateVTable(void*, int) {}
void XzProps_Init(void*) {}
int XzUnpacker_Code(void*, uint8_t*, size_t*, const uint8_t*, size_t*, int, int, void*) { return 0; }
void XzUnpacker_Construct(void*, void*) {}
void XzUnpacker_Free(void*) {}
void XzUnpacker_Init(void*, int) {}
void XzUnpacker_PrepareToRandomBlockDecoding(void*) {}
void XzUnpacker_SetOutBuf(void*, uint8_t*, size_t) {}
int Xz_Encode(void*, void*, void*, void*) { return 0; }
void Xzs_Construct(void*) {}
void Xzs_Free(void*, void*) {}
uint64_t Xzs_GetNumBlocks(void*) { return 0; }
int Xzs_ReadBackward(void*, void*, int64_t*, void*, void*) { return 0; }

} // extern "C"

// dVifUnpack template explicit instantiations (C++ linkage, not extern "C")
template<int idx> void dVifUnpack(const u8* data, bool isFill);
template<> void dVifUnpack<0>(const u8*, bool) {}
template<> void dVifUnpack<1>(const u8*, bool) {}

// =====================================================================
// Log stubs — Log.cpp does not exist in the repo
// =====================================================================
namespace Log {
  void Write(const char*, const char*, const char*, const char*) {}
  void WriteFmtArgs(const char*, const char*, const char*, fmt::string_view, fmt::format_args) {}
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

// ImGui::InputText(std::string*) stub — imgui_stdlib.cpp not available
typedef int ImGuiInputTextFlags;
typedef int (*ImGuiInputTextCallback)(void*);
namespace ImGui {
  bool InputText(const char* label, std::string* str,
      ImGuiInputTextFlags flags = 0,
      ImGuiInputTextCallback callback = nullptr,
      void* user_data = nullptr) {
    return false;
  }
}

struct SettingsInterface;
struct StateWrapper;
struct InputBindingKey {};
struct Pcsx2Config {};

// =====================================================================
// SDLInputSource stubs — SDL does not exist on iOS
// =====================================================================
namespace SDLInputSource {
  void ResetRGBForAllPlayers(SettingsInterface&) {}
}

// =====================================================================
// USB namespace stubs — not functional in bringup
// =====================================================================
namespace USB {
  std::string GetConfigDevice(const SettingsInterface&, u32) { return {}; }
  std::string GetConfigSubKey(std::string_view, std::string_view) { return {}; }
  std::string GetConfigSection(int) { return {}; }
  std::string GetConfigSubType(const SettingsInterface&, u32, std::string_view) { return {}; }
  std::vector<InputBindingKey> GetDeviceBindings(std::string_view, u32) { return {}; }
  std::vector<InputBindingKey> GetDeviceBindings(u32) { return {}; }
  std::string GetDeviceIconName(u32) { return {}; }
  float GetDeviceBindValue(u32, u32) { return 0.0f; }
  void SetDeviceBindValue(u32, u32, float) {}
  void InputDeviceConnected(std::string_view) {}
  void InputDeviceDisconnected(std::string_view) {}
  void CheckForConfigChanges(const Pcsx2Config&) {}
  std::string DeviceTypeIndexToName(int) { return {}; }
  int DeviceTypeNameToIndex(std::string_view) { return -1; }
  void SetDefaultConfiguration(SettingsInterface*) {}
  void DoState(StateWrapper&) {}
}
