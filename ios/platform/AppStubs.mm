// AppStubs.mm — BionicSX2 iOS Port
// Linked directly into BionicSX2_App target (NOT into libBionicSX2.a)
// All stubs use C++ linkage (mangled) — callers in libBionicSX2.a use C++ ABI

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

// Forward decls for types whose headers are unavailable (empty submodule)
namespace fmt {
    using string_view = std::string_view;
    struct format_args {};
}
struct StateWrapper;

// ══════════════════════════════════════════════════════
// C++ linkage symbols (no extern "C")
// ══════════════════════════════════════════════════════

// dVifRelease / dVifReset
void dVifRelease(int idx) {}
void dVifReset(int idx) {}

// DEV9CheckChanges — C++ linkage (takes Pcsx2Config&)
struct Pcsx2Config;
void DEV9CheckChanges(const Pcsx2Config&) {}

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

// ── isa_native::GSDrawScanline — inline implementation ──
namespace isa_native {
    struct GSRasterizerData;
    struct GSVector4i;
    struct GSVertexSW;
    struct GSScanlineLocalData;
    class GSDrawScanline {
    public:
        GSDrawScanline() {}
        ~GSDrawScanline() {}
        void BeginDraw(const GSRasterizerData&, GSScanlineLocalData&) {}
        void DrawRect(const GSVector4i&, const GSVertexSW&, GSScanlineLocalData&) {}
        void SetupDraw(GSRasterizerData&) {}
        void ResetCodeCache() {}
        void PrintStats() {}
    };
}
namespace bc7decomp { struct color_rgba; }

// ── SDLInputSource — inline implementation ─────────────
class SDLInputSource {
public:
    SDLInputSource() {}
    void ResetRGBForAllPlayers(SettingsInterface&) {}
};

// ── IOCtlSrc — physical disc, RED on iOS (Audit Sec 2.6) ─
class IOCtlSrc {
public:
    IOCtlSrc(std::string) {}
    ~IOCtlSrc() {}
    bool Reopen(Error*) { return false; }
    bool DiscReady() { return false; }
    int  GetMediaType() const { return -1; }
    unsigned int GetSectorCount() const { return 0; }
    int  GetLayerBreakAddress() const { return 0; }
    bool ReadTOC() const { return false; }
    bool ReadTrackSubQ(cdvdSubQ*) const { return false; }
    bool ReadSectors2048(unsigned int, unsigned int, unsigned char*) const { return false; }
    bool ReadSectors2352(unsigned int, unsigned int, unsigned char*) const { return false; }
};

// ── SaveStateBase::vuJITFreeze — JIT disabled on iOS ───
class SaveStateBase {
public:
    void vuJITFreeze() {}
};

// ── RGBA8Image — image loading stub ────────────────────
class RGBA8Image {
public:
    RGBA8Image() {}
    RGBA8Image(RGBA8Image&&) {}
    bool LoadFromBuffer(const char*, const void*, size_t) { return false; }
};

// ── MemoryInterface — Patch system write operations ────
class MemoryInterface {
public:
    void IdempotentWrite8(unsigned int, unsigned char) {}
    void IdempotentWrite16(unsigned int, unsigned short) {}
    void IdempotentWrite32(unsigned int, unsigned int) {}
    void IdempotentWrite64(unsigned int, unsigned long long) {}
    void IdempotentWriteBytes(unsigned int, void*, unsigned int) {}
};

// ── HTTPDownloader — use CFNet backend on iOS ──────────
class HTTPDownloader {
public:
    static std::unique_ptr<HTTPDownloader> Create(std::string) { return nullptr; }
};

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
void vtlb_DynBackpatchLoadStore(uptr code_address, u32 offset,
    u32 gpr_bitmask, u32 fpr_bitmask, u8 address_register,
    u8 data_register, u8 size_operand, bool is_load,
    bool is_signed, bool is_fpr) {}

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
void Discord_Initialize(const char* a, void* b, int c, const char* d) {}
void Discord_Shutdown() {}
void Discord_RunCallbacks() {}
void Discord_UpdatePresence(const void* p) {}
void Discord_ClearPresence() {}

// 7z / CRC
void CrcGenerateTable() {}
void Crc64GenerateTable() {}

// cplus_demangle
char* cplus_demangle(const char* m, int o) { return nullptr; }
int cplus_demangle_opname(const char* o, void* r, int f) { return 0; }

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

// ══════════════════════════════════════════════════════════════
// PASS 4 ADDITIONS — Linker Fix Pass 4
// ══════════════════════════════════════════════════════════════

// ── _g_Alloc — 7z allocator (C ABI global) ────────────────────
extern "C" {
    struct ISzAlloc {
        void* (*Alloc)(void*, size_t);
        void  (*Free)(void*, void*);
    };
    static void* SzAlloc(void*, size_t size) { return malloc(size); }
    static void  SzFree(void*, void* addr)   { free(addr); }
    ISzAlloc g_Alloc = { SzAlloc, SzFree };
}

// ── FullscreenUI missing functions ────────────────────────────
namespace FullscreenUI {
    void SwitchToSettings() {}
    void SwitchToGameSettings() {}
    void SwitchToGameSettings(const std::string&) {}
    void DrawSettingsWindow() {}
    void DrawInputBindingWindow() {}
    void CancelAllHddOperations() {}
    void SetSettingsChanged(void*) {}
    void PopulateGameListDirectoryCache(void*) {}
    bool IsEditingGameSettings(void*) { return false; }
    void* GetEditingSettingsInterface() { return nullptr; }
    void* GetEditingSettingsInterface(bool) { return nullptr; }
    bool GetEffectiveBoolSetting(void*, const char*, const char*, bool b) { return b; }
    void DrawFolderSetting(void*, const char*, const char*, const char*,
        const std::string&, float, std::pair<void*,float>,
        std::pair<void*,float>) {}
    void DrawToggleSetting(void*, const char*, const char*, const char*,
        const char*, bool, bool, bool, float,
        std::pair<void*,float>, std::pair<void*,float>) {}
    void DrawIntListSetting(void*, const char*, const char*, const char*,
        const char*, int, const char* const*, size_t, bool, int, bool,
        float, std::pair<void*,float>, std::pair<void*,float>) {}
}

// ── Log:: — correct signatures ────────────────────────────────
namespace Log {
    int GetMaxLevel() { return 0; }
    bool IsConsoleOutputEnabled() { return true; }
    bool IsFileOutputEnabled() { return false; }
    void SetConsoleOutputLevel(int) {}
    void SetFileOutputLevel(int, const std::string&) {}
    void SetTimestampsEnabled(bool) {}
    void Write(int, int, std::string_view) {}
    void Writev(int, int, const char*, char*) {}
    void WriteFmtArgs(int, int, std::string_view, const void*) {}
}

// ── Threading::WorkSema ───────────────────────────────────────
namespace Threading {
    struct WorkSema {
        void WaitForWork() {}
        void WaitForWorkWithSpin() {}
        bool CheckForWork() { return false; }
        void WaitForEmpty() {}
        void WaitForEmptyWithSpin(){}
        void Kill() {}
        void Reset() {}
    };
}

// ── FolderMemoryCard ─────────────────────────────────────────
class FolderMemoryCard {
public:
    FolderMemoryCard() {}
    ~FolderMemoryCard() {}
    bool Open(const std::string&, const void*, unsigned int, bool,
              const std::string&, bool) { return false; }
    void Close(bool) {}
    bool IsFormatted() const { return false; }
};
class FolderMemoryCardAggregator {
public:
    FolderMemoryCardAggregator() {}
    void Open() {}
    void Close() {}
    void SetFiltering(bool) {}
    bool IsPresent(unsigned int) { return false; }
    bool IsPSX(unsigned int) { return false; }
    void GetSizeInfo(unsigned int, void*) {}
    bool Read(unsigned int, unsigned char*, unsigned int, int) { return false; }
    bool Save(unsigned int, const unsigned char*, unsigned int, int) { return false; }
    bool EraseBlock(unsigned int, unsigned int) { return false; }
    unsigned long long GetCRC(unsigned int) { return 0; }
    void NextFrame(unsigned int) {}
    bool ReIndex(unsigned int, bool, const std::string&) { return false; }
};

// ── GameDatabase ─────────────────────────────────────────────
namespace GameDatabase {
    const void* findGame(std::string_view) { return nullptr; }
}
namespace GameDatabaseSchema {
    struct GameEntry {
        void applyGameFixes(void*, bool) const {}
        void applyGSHardwareFixes(void*) const {}
        std::string memcardFiltersAsString() const { return {}; }
        const void* findPatch(unsigned int) const { return nullptr; }
    };
}

// ── Host::OnAchievementsLoginRequested ────────────────────────
namespace Host {
    void OnAchievementsLoginRequested(int) {}
}

// ── InputManager keyboard stubs ──────────────────────────────
namespace InputManager {
    void* ConvertHostKeyboardStringToCode(std::string_view) { return nullptr; }
    std::string ConvertHostKeyboardCodeToString(unsigned int) { return {}; }
    void* ConvertHostKeyboardCodeToIcon(unsigned int) { return nullptr; }
}

// ── FileAccessHelper ──────────────────────────────────────────
class FileAccessHelper {
public:
    ~FileAccessHelper() {}
};
