// BionicSX2 — FmtLogStubs.cpp
// Pure C++ (not ObjC++) so template specializations compile cleanly.
// AUDIT REFERENCE: Phase 0-A

#include <string>
#include <locale>
#include <string_view>
#include <cstdint>
#include <cstdarg>

// ── Minimal fmt v12 ABI types (must match 3rdparty/fmt layout) ───────────────
namespace fmt {
inline namespace v12 {

struct string_view_ref {
    const char* data_;
    std::size_t size_;
};

struct format_args_ref {
    const void* types_;
    const void* values_;
    int         size_;
};

struct locale_ref {
    const void* locale_;

    template <typename Locale>
    Locale get() const { return Locale(); }
};

namespace detail {
    struct buffer_base {
        char*       ptr_     = nullptr;
        std::size_t size_    = 0;
        std::size_t capacity_= 0;
        virtual void grow(std::size_t) {}
        virtual ~buffer_base() {}
    };

    template <typename T>
    struct buffer : buffer_base {};

    void vformat_to(buffer<char>&, string_view_ref, format_args_ref, locale_ref) {}
    bool is_printable(unsigned int) { return true; }
}

std::string vformat(string_view_ref, format_args_ref) { return {}; }
void        report_error(const char*) {}

// Explicit instantiation so the mangled symbol exists in this TU
template std::locale locale_ref::get<std::locale>() const;

} // v12
} // fmt

// ── Log namespace (LOGLEVEL / ConsoleColors are plain enums in PCSX2) ─────────
// We reproduce the minimal enum values needed to match the ABI mangling.
enum LOGLEVEL : unsigned int {
    LOGLEVEL_NONE=0, LOGLEVEL_ERROR, LOGLEVEL_WARNING, LOGLEVEL_PERF,
    LOGLEVEL_INFO, LOGLEVEL_VERBOSE, LOGLEVEL_DEV, LOGLEVEL_DEBUG,
    LOGLEVEL_TRACE, LOGLEVEL_BULK
};
enum ConsoleColors : unsigned int { Color_Default = 0 };

namespace Log {
    void Write(LOGLEVEL, ConsoleColors, std::string_view) {}
    void Writev(LOGLEVEL, ConsoleColors, const char*, va_list) {}
    void WriteFmtArgs(LOGLEVEL, ConsoleColors,
                      fmt::v12::string_view_ref,
                      fmt::v12::format_args_ref) {}
    LOGLEVEL    GetMaxLevel()              { return LOGLEVEL_NONE; }
    bool        IsConsoleOutputEnabled()   { return false; }
    bool        IsFileOutputEnabled()      { return false; }
    void        SetConsoleOutputLevel(LOGLEVEL) {}
    void        SetFileOutputLevel(LOGLEVEL, std::string) {}
    void        SetTimestampsEnabled(bool) {}
}
