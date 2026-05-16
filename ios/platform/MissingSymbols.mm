// MissingSymbols.mm — Self-contained stubs, NO external headers
// All types redeclared manually to avoid #include dependency
// AUDIT REFERENCE: Phase 0-F all categories
// BionicSX2 iOS Port

#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string>
#include <string_view>
#include <vector>
#include <memory>
#include <optional>
#include <locale>
#include <atomic>

// ── Primitive types (matches PCSX2 typedefs) ─────────────────
typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned int   u32;
typedef unsigned long long u64;
typedef signed char    s8;
typedef signed short   s16;
typedef signed int     s32;
typedef signed long long s64;

// ══════════════════════════════════════════════════════════════
// GROUP 1: C-ABI symbols (_prefix) — extern "C" required
// ══════════════════════════════════════════════════════════════
extern "C" {
    // Discord
    void Discord_Initialize(const char*, void*, int, const char*) {}
    void Discord_Shutdown(void) {}
    void Discord_RunCallbacks(void) {}
    void Discord_UpdatePresence(const void*) {}
    void Discord_ClearPresence(void) {}

    // CRC / 7z
    void CrcGenerateTable(void) {}
    void Crc64GenerateTable(void) {}

    // cplus_demangle
    char* cplus_demangle(const char*, int) { return nullptr; }
    int   cplus_demangle_opname(const char*, void*, int) { return 0; }

    // _g_Alloc (7z allocator)
    typedef struct {
        void* (*Alloc)(void*, size_t);
        void  (*Free)(void*, void*);
    } ISzAllocT;
    static void* _sz_alloc(void*, size_t s) { return malloc(s); }
    static void  _sz_free(void*, void* p)   { free(p); }
    ISzAllocT g_Alloc = { _sz_alloc, _sz_free };
}

// ══════════════════════════════════════════════════════════════
// GROUP 2: vtlb_DynBackpatchLoadStore — C++ ABI
// ══════════════════════════════════════════════════════════════
void vtlb_DynBackpatchLoadStore(
    unsigned long, unsigned int, unsigned int, unsigned int,
    unsigned int,  unsigned int, unsigned char, unsigned char,
    unsigned char, bool, bool, bool) {}

// ══════════════════════════════════════════════════════════════
// GROUP 3: dVifUnpack explicit template specializations
// ══════════════════════════════════════════════════════════════
template<int idx> void dVifUnpack(const u8*, bool);
template<> void dVifUnpack<0>(const u8*, bool) {}
template<> void dVifUnpack<1>(const u8*, bool) {}

// ══════════════════════════════════════════════════════════════
// GROUP 4: isa_native::GSDrawScanline — complete class body
// ══════════════════════════════════════════════════════════════
namespace isa_native {
    struct GSRasterizerData {};
    struct GSScanlineLocalData {};
    struct GSVector4i {};
    struct GSVertexSW {};

    class GSDrawScanline {
    public:
        int _pad[4] = {};
        GSDrawScanline() {}
        ~GSDrawScanline() {}
        void BeginDraw(const GSRasterizerData&,
                       GSScanlineLocalData&) {}
        void DrawRect(const GSVector4i&,
                      const GSVertexSW&,
                      GSScanlineLocalData&) {}
        void SetupDraw(GSRasterizerData&) {}
        void ResetCodeCache() {}
        void PrintStats() {}
    };
}

// ══════════════════════════════════════════════════════════════
// GROUP 5: Log:: — exact signatures from nm output
// ══════════════════════════════════════════════════════════════
namespace fmt { namespace v12 {
    template<typename Char> class basic_string_view;
    using string_view = basic_string_view<char>;
    template<typename Context> class basic_format_args;
    struct context;
    using format_args = basic_format_args<context>;
}}

typedef int LOGLEVEL;
typedef int ConsoleColors;

namespace Log {
    LOGLEVEL GetMaxLevel()             { return 4; }
    bool IsConsoleOutputEnabled()      { return true; }
    bool IsFileOutputEnabled()         { return false; }
    void SetConsoleOutputLevel(LOGLEVEL) {}
    void SetFileOutputLevel(LOGLEVEL, std::string) {}
    void SetTimestampsEnabled(bool)    {}
    void Write(LOGLEVEL, ConsoleColors,
               std::string_view msg) {
        NSLog(@"[PCSX2] %.*s", (int)msg.size(), msg.data());
    }
    void Writev(LOGLEVEL, ConsoleColors,
                const char* fmt_str, char*) {
        NSLog(@"[PCSX2] %s", fmt_str);
    }
    void WriteFmtArgs(LOGLEVEL, ConsoleColors,
                      fmt::v12::string_view,
                      fmt::v12::format_args) {}
}

// ══════════════════════════════════════════════════════════════
// GROUP 6: fmt::v12 — exact symbols from nm
// ══════════════════════════════════════════════════════════════
namespace fmt { namespace v12 {
    void report_error(const char* msg) {
        NSLog(@"[fmt] %s", msg);
    }

    std::string vformat(string_view fmt_str, format_args) {
        return std::string(fmt_str.data(),
                           fmt_str.data() + fmt_str.size());
    }

    namespace detail {
        template<typename T> class buffer {
        public:
            virtual void grow(size_t) {}
            T* begin() { return nullptr; }
            T* end()   { return nullptr; }
            void append(const T*, const T*) {}
        };

        void vformat_to(buffer<char>&, string_view,
                        format_args, ...) {}

        bool is_printable(unsigned int) { return true; }
    }

    struct locale_ref {
        template<typename T> T get() const;
    };
    template<>
    std::locale locale_ref::get<std::locale>() const {
        return std::locale::classic();
    }
}}

// ══════════════════════════════════════════════════════════════
// GROUP 7: Threading::WorkSema — exact signatures
// ══════════════════════════════════════════════════════════════
namespace Threading {
    class WorkSema {
        std::atomic<int> _state{0};
    public:
        void WaitForWork()          {}
        void WaitForWorkWithSpin()  {}
        bool CheckForWork()         { return false; }
        void WaitForEmpty()         {}
        void WaitForEmptyWithSpin() {}
        void Kill()                 {}
        void Reset()                {}
        void NotifyOfWork(int = 1)  {}
    };
}

// ══════════════════════════════════════════════════════════════
// GROUP 8: AudioStream backends
// ══════════════════════════════════════════════════════════════
struct AudioStreamParameters {};
struct Error {};

class AudioStream {
public:
    struct DeviceInfo { std::string name, display_name; };
    static std::unique_ptr<AudioStream>
    CreateCubebAudioStream(u32, const AudioStreamParameters&,
        const char*, const char*, bool, Error*)
        { return nullptr; }
    static std::unique_ptr<AudioStream>
    CreateSDLAudioStream(u32, const AudioStreamParameters&,
        bool, Error*)
        { return nullptr; }
    static std::vector<std::string>
    GetCubebDriverNames()
        { return {}; }
    static std::vector<DeviceInfo>
    GetCubebOutputDevices(const char*)
        { return {}; }
};

// ══════════════════════════════════════════════════════════════
// GROUP 9: SDLInputSource
// ══════════════════════════════════════════════════════════════
struct SettingsInterface {};

class SDLInputSource {
public:
    SDLInputSource() {}
    void ResetRGBForAllPlayers(SettingsInterface&) {}
};

// ══════════════════════════════════════════════════════════════
// GROUP 10: IOCtlSrc — physical disc RED on iOS
// ══════════════════════════════════════════════════════════════
struct cdvdSubQ {};

class IOCtlSrc {
public:
    IOCtlSrc(std::string) {}
    ~IOCtlSrc() {}
    bool Reopen(Error*)           { return false; }
    bool DiscReady()              { return false; }
    s32  GetMediaType() const     { return -1; }
    u32  GetSectorCount() const   { return 0; }
    s32  GetLayerBreakAddress() const { return 0; }
    bool ReadTOC() const          { return false; }
    bool ReadTrackSubQ(cdvdSubQ*) const { return false; }
    bool ReadSectors2048(u32, u32, u8*) const { return false; }
    bool ReadSectors2352(u32, u32, u8*) const { return false; }
};

// ══════════════════════════════════════════════════════════════
// GROUP 11: MemoryInterface
// ══════════════════════════════════════════════════════════════
class MemoryInterface {
public:
    template<typename T>
    bool IdempotentWrite(u32, T)  { return true; }
    void IdempotentWrite8(u32, u8)   {}
    void IdempotentWrite16(u32, u16) {}
    void IdempotentWrite32(u32, u32) {}
    void IdempotentWrite64(u32, u64) {}
    void IdempotentWriteBytes(u32, void*, u32) {}
};

// ══════════════════════════════════════════════════════════════
// GROUP 12: FolderMemoryCard
// ══════════════════════════════════════════════════════════════
struct McdSizeInfo {};
namespace Pcsx2Config { struct McdOptions {}; }

class FileAccessHelper {
public:
    ~FileAccessHelper() {}
};

class FolderMemoryCard {
public:
    FolderMemoryCard() {}
    ~FolderMemoryCard() {}
    bool Open(std::string, const Pcsx2Config::McdOptions&,
              u32, bool, std::string, bool) { return false; }
    void Close(bool) {}
    bool IsFormatted() const { return false; }
};

class FolderMemoryCardAggregator {
public:
    FolderMemoryCardAggregator() {}
    void Open()              {}
    void Close()             {}
    void SetFiltering(bool)  {}
    bool IsPresent(u32)      { return false; }
    bool IsPSX(u32)          { return false; }
    void GetSizeInfo(u32, McdSizeInfo&) {}
    bool Read(u32, u8*, u32, int)  { return false; }
    bool Save(u32, const u8*, u32, int) { return false; }
    bool EraseBlock(u32, u32)      { return false; }
    u64  GetCRC(u32)               { return 0; }
    void NextFrame(u32)            {}
    bool ReIndex(u32, bool, const std::string&) { return false; }
};

// ══════════════════════════════════════════════════════════════
// GROUP 13: GameDatabase / GameDatabaseSchema
// ══════════════════════════════════════════════════════════════
namespace Pcsx2Config { struct GSOptions {}; }

namespace GameDatabaseSchema {
    struct GameEntry {
        void applyGameFixes(void*, bool) const {}
        void applyGSHardwareFixes(void*) const {}
        std::string memcardFiltersAsString() const { return {}; }
        const void* findPatch(u32) const { return nullptr; }
    };
}
namespace GameDatabase {
    const GameDatabaseSchema::GameEntry*
    findGame(std::string_view) { return nullptr; }
}

// ══════════════════════════════════════════════════════════════
// GROUP 14: SaveStateBase::vuJITFreeze
// ══════════════════════════════════════════════════════════════
class SaveStateBase {
public:
    void vuJITFreeze() {}
};

// ══════════════════════════════════════════════════════════════
// GROUP 15: HTTPDownloader
// ══════════════════════════════════════════════════════════════
class HTTPDownloader {
public:
    static std::unique_ptr<HTTPDownloader>
    Create(std::string) { return nullptr; }
};

// ══════════════════════════════════════════════════════════════
// GROUP 16: bc7decomp
// ══════════════════════════════════════════════════════════════
namespace bc7decomp {
    struct color_rgba { u8 r, g, b, a; };
    bool unpack_bc7(const void*, color_rgba*) { return false; }
}

// ══════════════════════════════════════════════════════════════
// GROUP 17: RGBA8Image
// ══════════════════════════════════════════════════════════════
class RGBA8Image {
public:
    RGBA8Image() {}
    RGBA8Image(RGBA8Image&&) {}
    bool LoadFromBuffer(const char*, const void*,
                        size_t) { return false; }
};

// ══════════════════════════════════════════════════════════════
// GROUP 18: FullscreenUI missing functions
// ══════════════════════════════════════════════════════════════
struct ImFont {};

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
    SettingsInterface* GetEditingSettingsInterface()
        { return nullptr; }
    SettingsInterface* GetEditingSettingsInterface(bool)
        { return nullptr; }
    bool GetEffectiveBoolSetting(SettingsInterface*,
        const char*, const char*, bool b) { return b; }
    void DrawFolderSetting(SettingsInterface*,
        const char*, const char*, const char*,
        const std::string&, float, FontPair, FontPair) {}
    void DrawToggleSetting(SettingsInterface*,
        const char*, const char*, const char*, const char*,
        bool, bool, bool, float, FontPair, FontPair) {}
    void DrawIntListSetting(SettingsInterface*,
        const char*, const char*, const char*, const char*,
        int, const char* const*, size_t,
        bool, int, bool, float, FontPair, FontPair) {}
}

// ══════════════════════════════════════════════════════════════
// GROUP 19: Host::OnAchievementsLoginRequested
// ══════════════════════════════════════════════════════════════
namespace Host {
    void OnAchievementsLoginRequested(int) {}
}

// ══════════════════════════════════════════════════════════════
// GROUP 20: InputManager keyboard
// ══════════════════════════════════════════════════════════════
namespace InputManager {
    std::optional<u32>
    ConvertHostKeyboardStringToCode(std::string_view)
        { return std::nullopt; }
    std::string
    ConvertHostKeyboardCodeToString(u32) { return {}; }
    std::optional<std::string>
    ConvertHostKeyboardCodeToIcon(u32) { return std::nullopt; }
}

// ══════════════════════════════════════════════════════════════
// GROUP 21: USB:: — correct signatures (SettingsInterface ref)
// ══════════════════════════════════════════════════════════════
namespace USB {
    std::string_view GetConfigDevice(
        const SettingsInterface&, u32) { return ""; }
    std::string_view GetConfigSubType(
        const SettingsInterface&, u32,
        std::string_view) { return ""; }
    void SetDefaultConfiguration(SettingsInterface*) {}
}

// ══════════════════════════════════════════════════════════════
// GROUP 22: _g_host_hotkeys
// ══════════════════════════════════════════════════════════════
struct HotkeyInfo {};
const HotkeyInfo* g_host_hotkeys = nullptr;
