// AppStubs.mm — BionicSX2 iOS Port
// Linked directly into BionicSX2_App target (NOT into libBionicSX2.a)
// All stubs use C++ linkage (mangled) — callers in libBionicSX2.a use C++ ABI

// vtlb_DynBackpatchLoadStore — must be C++ linkage to match vtlb.cpp call site
void vtlb_DynBackpatchLoadStore(
    unsigned long, unsigned int, unsigned int, unsigned int,
    unsigned int,  unsigned int, unsigned char, unsigned char,
    unsigned char, bool, bool, bool) {}

#include <cstdlib>
#include <cstdint>
#include <cstdio>
#include <string>
#include <functional>
#include <vector>
#include <memory>
#include <string_view>
#include <libkern/OSCacheControl.h>

// PCSX2 type aliases (Pcsx2Types.h unavailable — empty submodule)
using u8  = std::uint8_t;
using u16 = std::uint16_t;
using u32 = std::uint32_t;
using u64 = std::uint64_t;
using s32 = std::int32_t;
using uptr = std::uintptr_t;

struct StateWrapper;

// ══════════════════════════════════════════════════════
// C++ linkage symbols (no extern "C")
// ══════════════════════════════════════════════════════

// GetValidDrive — takes std::string&
void GetValidDrive(std::string& s) {}

// ── Common::InhibitScreensaver ────────────────────────
namespace Common {
    void InhibitScreensaver(bool inhibit) {}
}

// ── USB:: namespace stubs ─────────────────────────────
#include <string_view>
namespace USB {
    std::string_view GetConfigSection(int port) { return ""; }
    std::string_view GetConfigDevice(const void*, unsigned int) { return ""; }
    std::string_view GetConfigSubKey(std::string_view, std::string_view) { return ""; }
    std::string_view GetConfigSubType(const void*, unsigned int, std::string_view) { return ""; }
    void* GetDeviceBindings(std::string_view, unsigned int) { return nullptr; }
    void* GetDeviceBindings(unsigned int) { return nullptr; }
    std::string_view GetDeviceIconName(unsigned int) { return ""; }
    float GetDeviceBindValue(unsigned int, unsigned int) { return 0.f; }
    void SetDeviceBindValue(unsigned int, unsigned int, float) {}
    void InputDeviceConnected(std::string_view) {}
    void InputDeviceDisconnected(std::string_view) {}
    void CheckForConfigChanges(const Pcsx2Config&) {}
    std::string_view DeviceTypeIndexToName(int) { return ""; }
    int DeviceTypeNameToIndex(std::string_view) { return -1; }
    void SetDefaultConfiguration(void*) {}
    void DoState(StateWrapper&) {}
}

// ── ImGuiFreeType stubs ───────────────────────────────
struct ImFontBuilderIO;
namespace ImGuiFreeType {
    const ImFontBuilderIO* GetFontLoader() { return nullptr; }
}

// ── ImGui::InputText(std::string*) stub ───────────────
struct ImGuiInputTextCallbackData;
typedef int ImGuiInputTextFlags;
typedef int (*ImGuiInputTextCallback)(ImGuiInputTextCallbackData*);
namespace ImGui {
    bool InputText(const char*, std::string*, int,
        ImGuiInputTextCallback, void*) { return false; }
}

// ── Forward declarations ─────────────────────────────
struct SettingsInterface;
struct InputBindingKey {};
struct HotkeyInfo;
struct cdvdSubQ;
struct Error;

// NOTE: GSDrawScanline symbols provided by GSDrawScanlineStub.s (ARM64 asm with exact mangling)
// ══════════════════════════════════════════════════════════════
// C-ABI stubs — moved from CStubs.c (C files produce wrong ABI)
// These must use C++ linkage to match callers in libBionicSX2.a
// ══════════════════════════════════════════════════════════════

// DEV9
void DEV9init() {}
void DEV9open() {}
void DEV9close() {}
void DEV9shutdown() {}
void DEV9async(u32 x) {}
void DEV9irqHandler() {}
u8   DEV9read8(u32 addr)  { return 0; }
u16  DEV9read16(u32 addr) { return 0; }
u32  DEV9read32(u32 addr) { return 0; }
void DEV9write8(u32 addr, u8 val)   {}
void DEV9write16(u32 addr, u16 val) {}
void DEV9write32(u32 addr, u32 val) {}
void DEV9readDMA8Mem(u32* dst, int size)  {}
void DEV9writeDMA8Mem(u32* src, int size) {}

// USB
void USBinit() {}
void USBopen() {}
void USBclose() {}
void USBshutdown() {}
void USBreset() {}
void USBasync(u32 x) {}
u8   USBread8(u32 addr)  { return 0; }
u16  USBread16(u32 addr) { return 0; }
u32  USBread32(u32 addr) { return 0; }
void USBwrite8(u32 addr, u8 val)   {}
void USBwrite16(u32 addr, u16 val) {}
void USBwrite32(u32 addr, u32 val) {}

// VIF — Category 1 (Phase 0-B)
void VifUnpackSSE_Init() {}

// Misc
void ShortSpin() {}
void GetOpticalDriveList() {}
void GetMetalAdapterList() {}

// Memory alignment
void* _aligned_malloc(size_t size, size_t align) {
    void* p = nullptr;
    if (align < sizeof(void*)) align = sizeof(void*);
    posix_memalign(&p, align, size);
    return p;
}
void _aligned_free(void* p) { free(p); }

// Assert
void pxOnAssertFail(const char* msg, int line,
                    const char* file, const char* func) {
    fprintf(stderr, "[BionicSX2] Assert %s:%d %s: %s\n",
            file, line, func, msg);
    abort();
}

// BC decompression
void DecompressBlockBC1(u32 x, u32 y, u32 z,
    const u8* s, u8* d) {}
void DecompressBlockBC2(u32 x, u32 y, u32 z,
    const u8* s, u8* d) {}
void DecompressBlockBC3(u32 x, u32 y, u32 z,
    const u8* s, u8* d) {}

// Discord
extern "C" void Discord_Initialize(const char*, void*, int, const char*) {}
extern "C" void Discord_Shutdown() {}
extern "C" void Discord_RunCallbacks() {}
extern "C" void Discord_UpdatePresence(const void*) {}
extern "C" void Discord_ClearPresence() {}

// 7z / CRC
extern "C" void CrcGenerateTable(void) {}
extern "C" void Crc64GenerateTable(void) {}

// cplus_demangle
extern "C" char* cplus_demangle(const char*, int) { return nullptr; }
extern "C" int   cplus_demangle_opname(const char*, char*, int) { return 0; }

// ══════════════════════════════════════════════════════════════
// _g_host_hotkeys — empty hotkey list on iOS
// ══════════════════════════════════════════════════════════════
const HotkeyInfo* g_host_hotkeys = nullptr;

// ══════════════════════════════════════════════════════════════
// ___clear_cache — iOS uses sys_icache_invalidate instead of
// __builtin___clear_cache. This C-linkage symbol is referenced
// from LnxHostSys.cpp.o inside libBionicSX2.a.
// ══════════════════════════════════════════════════════════════
extern "C" void __clear_cache(void* start, void* end) {
    sys_icache_invalidate(start,
        static_cast<size_t>(
            static_cast<char*>(end) - static_cast<char*>(start)));
}

// ════════════════════════════════════════════════════════════════════════════
// WAVE-2 STUBS — AppStubs.mm addition
// AUDIT REFERENCE: Phase 0-A, Sections 2.3-ADDENDUM, 13.7
// ════════════════════════════════════════════════════════════════════════════

#include <stdint.h>
#include <stddef.h>
#include <string>
#include <string_view>
#include <vector>

// ── GROUP C: 7z / LZMA — GS dump dead code on iOS ───────────────────────────
extern "C" {
  // ISzAlloc global
  struct ISzAlloc { void* (*Alloc)(void*, size_t); void (*Free)(void*, void*); };
  static void* _stub_alloc(void*, size_t s) { return malloc(s); }
  static void  _stub_free(void*, void* p)   { free(p); }
  ISzAlloc g_Alloc = { _stub_alloc, _stub_free };

  // XzUnpacker
  struct CXzUnpacker; struct CXzs; struct ILookInStream;
  void XzUnpacker_Construct(CXzUnpacker*, const ISzAlloc*) {}
  void XzUnpacker_Free(CXzUnpacker*) {}
  void XzUnpacker_Init(CXzUnpacker*) {}
  void XzUnpacker_PrepareToRandomBlockDecoding(CXzUnpacker*) {}
  void XzUnpacker_SetOutBuf(CXzUnpacker*, uint8_t*, size_t) {}
  int  XzUnpacker_Code(CXzUnpacker*, uint8_t*, size_t*, const uint8_t*, size_t*, int, int, size_t*) { return 0; }

  // Xzs
  void Xzs_Construct(CXzs*) {}
  void Xzs_Free(CXzs*, const ISzAlloc*) {}
  int  Xzs_ReadBackward(CXzs*, ILookInStream*, int64_t*, void*, const ISzAlloc*) { return 0; }
  int64_t Xzs_GetNumBlocks(const CXzs*) { return 0; }

  // Xz encode
  void XzProps_Init(void*) {}
  int  Xz_Encode(void*, void*, void*, void*, void*) { return 0; }

  // LookToRead2
  void LookToRead2_CreateVTable(void*, int) {}
}

// ── GROUP D: ZSTD — GS dump compression, dead on iOS ────────────────────────
extern "C" {
  struct ZSTD_CStream; enum ZSTD_EndDirective { ZSTD_e_continue=0, ZSTD_e_flush, ZSTD_e_end };
  ZSTD_CStream* ZSTD_createCStream(void) { return nullptr; }
  size_t ZSTD_freeCStream(ZSTD_CStream*) { return 0; }
  size_t ZSTD_CCtx_setParameter(ZSTD_CStream*, int, int) { return 0; }
  size_t ZSTD_compressStream2(ZSTD_CStream*, void*, void*, ZSTD_EndDirective) { return 0; }
}

// ── GROUP E: dVifUnpack JIT — interpreter path only on iOS ──────────────────
// These are C++ template instantiations — must match mangled names exactly
// Stubs go in extern "C++" scope (default)
template<int idx> void dVifUnpack(const uint8_t*, bool) {}
template void dVifUnpack<0>(const uint8_t*, bool);
template void dVifUnpack<1>(const uint8_t*, bool);

// ── GROUP G: FullscreenUI settings functions ─────────────────────────────────
struct SettingsInterface;
struct ImFont;
namespace FullscreenUI {
  using FontPair = std::pair<ImFont*, float>;
  void SwitchToSettings() {}
  void SwitchToGameSettings() {}
  void SwitchToGameSettings(const std::string&) {}
  void DrawSettingsWindow() {}
  void DrawInputBindingWindow() {}
  void CancelAllHddOperations() {}
  void SetSettingsChanged(SettingsInterface*) {}
  void PopulateGameListDirectoryCache(SettingsInterface*) {}
  bool IsEditingGameSettings(SettingsInterface*) { return false; }
  bool GetEffectiveBoolSetting(SettingsInterface*, const char*, const char*, bool def) { return def; }
  SettingsInterface* GetEditingSettingsInterface() { return nullptr; }
  SettingsInterface* GetEditingSettingsInterface(bool) { return nullptr; }
  void DrawFolderSetting(SettingsInterface*, const char*, const char*, const char*,
    const std::string&, float, FontPair, FontPair) {}
  void DrawToggleSetting(SettingsInterface*, const char*, const char*, const char*,
    const char*, bool, bool, bool, float, FontPair, FontPair) {}
  void DrawIntListSetting(SettingsInterface*, const char*, const char*, const char*,
    const char*, int, const char* const*, size_t, bool, int, bool, float, FontPair, FontPair) {}
}

// ── GROUP H: Miscellaneous ───────────────────────────────────────────────────

// GameDatabase::findGame
namespace GameDatabaseSchema { struct GameEntry {}; }
namespace GameDatabase {
  const GameDatabaseSchema::GameEntry* findGame(std::string_view) { return nullptr; }
}

// InputManager keyboard host stubs
namespace InputManager {
  uint32_t ConvertHostKeyboardStringToCode(std::string_view) { return 0; }
  std::string ConvertHostKeyboardCodeToString(uint32_t) { return {}; }
  const char* ConvertHostKeyboardCodeToIcon(uint32_t) { return nullptr; }
}

// USB stubs
namespace USB {
  std::string GetConfigDevice(const SettingsInterface&, uint32_t) { return {}; }
  std::string GetConfigSubType(const SettingsInterface&, uint32_t, std::string_view) { return {}; }
  void SetDefaultConfiguration(SettingsInterface*) {}
}

// bc7decomp — texture decompression, stub on iOS
namespace bc7decomp {
  struct color_rgba { uint8_t r,g,b,a; };
  bool unpack_bc7(const void*, color_rgba*) { return false; }
}


