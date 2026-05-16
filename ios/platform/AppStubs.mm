// AppStubs.mm — BionicSX2 iOS Port
// Linked directly into BionicSX2_App target (NOT into libBionicSX2.a)
// All C-ABI stubs use extern "C"

#include <cstdlib>
#include <cstdio>
#include <string>
#include <functional>
#include <vector>
#include <memory>

#ifdef __cplusplus
extern "C" {
#endif

// ── DEV9 ──────────────────────────────────────────────
void DEV9init(void) {}
void DEV9open(void) {}
void DEV9close(void) {}
void DEV9shutdown(void) {}
void DEV9async(unsigned int x) {}
void DEV9irqHandler(void) {}
unsigned char  DEV9read8(unsigned int addr)  { return 0; }
unsigned short DEV9read16(unsigned int addr) { return 0; }
unsigned int   DEV9read32(unsigned int addr) { return 0; }
void DEV9write8(unsigned int addr, unsigned char val)   {}
void DEV9write16(unsigned int addr, unsigned short val) {}
void DEV9write32(unsigned int addr, unsigned int val)   {}
void DEV9readDMA8Mem(unsigned int* dst, int size)  {}
void DEV9writeDMA8Mem(unsigned int* src, int size) {}

// ── USB ───────────────────────────────────────────────
void USBinit(void) {}
void USBopen(void) {}
void USBclose(void) {}
void USBshutdown(void) {}
void USBreset(void) {}
void USBasync(unsigned int x) {}
unsigned char  USBread8(unsigned int addr)  { return 0; }
unsigned short USBread16(unsigned int addr) { return 0; }
unsigned int   USBread32(unsigned int addr) { return 0; }
void USBwrite8(unsigned int addr, unsigned char val)   {}
void USBwrite16(unsigned int addr, unsigned short val) {}
void USBwrite32(unsigned int addr, unsigned int val)   {}

// ── VIF / JIT ─────────────────────────────────────────
void VifUnpackSSE_Init(void) {}
void vtlb_DynBackpatchLoadStore(unsigned long a, unsigned int b,
    unsigned int c, unsigned int d, unsigned int e, unsigned int f,
    unsigned char g, unsigned char h, unsigned char i,
    bool j, bool k, bool l) {}

// ── Drive / Disc ──────────────────────────────────────
void GetOpticalDriveList(void) {}
void GetMetalAdapterList(void) {}
void ShortSpin(void) {}

// ── Memory alignment ──────────────────────────────────
void* _aligned_malloc(unsigned long size, unsigned long align) {
    void* p = NULL;
    posix_memalign(&p, align < sizeof(void*) ? sizeof(void*) : align, size);
    return p;
}
void _aligned_free(void* p) { free(p); }

// ── Assert ────────────────────────────────────────────
void pxOnAssertFail(const char* msg, int line,
                    const char* file, const char* func) {
    fprintf(stderr, "[BionicSX2] Assert %s:%d %s: %s\n", file, line, func, msg);
    abort();
}

// ── BC texture decompression ──────────────────────────
void DecompressBlockBC1(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* s, unsigned char* d) {}
void DecompressBlockBC2(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* s, unsigned char* d) {}
void DecompressBlockBC3(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* s, unsigned char* d) {}

// ── Discord Rich Presence ─────────────────────────────
void Discord_Initialize(const char* a, void* b, int c, const char* d) {}
void Discord_Shutdown(void) {}
void Discord_RunCallbacks(void) {}
void Discord_UpdatePresence(const void* p) {}
void Discord_ClearPresence(void) {}

// ── 7-zip / LZMA (GSDump) ────────────────────────────
void CrcGenerateTable(void) {}
void Crc64GenerateTable(void) {}

#ifdef __cplusplus
} // extern "C"
#endif

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

// ── Threading::WorkSema ───────────────────────────────
namespace Threading {
    void WorkSema::WaitForWork() {}
    bool WorkSema::WaitForEmpty() { return true; }
}

// ── Log:: implementation ──────────────────────────────
namespace Log {
    void Write(const char*, const char*, const char*, const char*) {}
    void WriteFmtArgs(const char*, const char*, const char*,
        fmt::string_view, fmt::format_args) {}
}

// ── SDLInputSource stub ───────────────────────────────
namespace SDLInputSource {
    void ResetRGBForAllPlayers(void*) {}
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
    void DoState(void&) {}
}

// ── ImGuiFreeType stubs ───────────────────────────────
struct ImFontBuilderIO;
namespace ImGuiFreeType {
    const ImFontBuilderIO* GetFontLoader() { return nullptr; }
}

// ── ImGui::InputText(std::string*) stub ───────────────
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

// ── _cplus_demangle ───────────────────────────────────
extern "C" {
    char* cplus_demangle(const char* mangled, int options) { return nullptr; }
    int cplus_demangle_opname(const char* opname, void* result, int options) { return 0; }
}

// ── Forward declarations for types used in ImGui code ─
struct SettingsInterface;
struct StateWrapper;
struct InputBindingKey {};
