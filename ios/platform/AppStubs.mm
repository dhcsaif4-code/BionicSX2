// AppStubs.mm — BionicSX2 iOS Port
// Linked directly into BionicSX2_App target (NOT into libBionicSX2.a)
// All C-ABI stubs use extern "C"

#include <cstdlib>
#include <cstdio>
#include <string>
#include <functional>
#include <vector>
#include <memory>
#include <string_view>

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

// ── Threading::WorkSema ───────────────────────────────
namespace Threading {
    struct WorkSema {
        void WaitForWork() {}
        bool WaitForEmpty() { return true; }
    };
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
    void DoState(StateWrapper&) {}
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

// ── Forward declarations for types used in ImGui code ─
struct SettingsInterface;
struct InputBindingKey {};
