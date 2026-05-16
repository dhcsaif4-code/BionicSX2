// BionicSX2 — FmtLogStubs.cpp
// Uses REAL fmt headers so mangled names match libBionicSX2.a exactly.
// AUDIT REFERENCE: Phase 0-A

// Tell fmt this is NOT a header-only build — we provide the definitions here
#define FMT_HEADER_ONLY 0

#include "../../3rdparty/fmt/include/fmt/format.h"
#include "../../3rdparty/fmt/include/fmt/format-inl.h"

#include <string>
#include <locale>
#include <string_view>
#include <cstdarg>

// ── Provide the non-inline fmt symbols the linker needs ──────────────────────
namespace fmt {
FMT_BEGIN_NAMESPACE
namespace detail {
    template void vformat_to(buffer<char>&, basic_string_view<char>,
                             basic_format_args<context>, locale_ref);
    FMT_FUNC bool is_printable(uint32_t cp);
}
FMT_FUNC std::string vformat(basic_string_view<char>, basic_format_args<context>);
FMT_FUNC void report_error(const char*);
template FMT_FUNC std::locale locale_ref::get<std::locale>() const;
FMT_END_NAMESPACE
}

// ── LOGLEVEL / ConsoleColors — must match common/Logging.h ABI exactly ───────
enum LOGLEVEL : unsigned int {
    LOGLEVEL_NONE=0, LOGLEVEL_ERROR, LOGLEVEL_WARNING, LOGLEVEL_PERF,
    LOGLEVEL_INFO, LOGLEVEL_VERBOSE, LOGLEVEL_DEV, LOGLEVEL_DEBUG,
    LOGLEVEL_TRACE, LOGLEVEL_BULK
};
enum ConsoleColors : unsigned int { Color_Default=0 };

// ── Log stubs — use real fmt types so mangling matches ───────────────────────
namespace Log {
    void Write(LOGLEVEL, ConsoleColors, std::string_view) {}
    void Writev(LOGLEVEL, ConsoleColors, const char*, char*) {}
    void WriteFmtArgs(LOGLEVEL level, ConsoleColors color,
                      fmt::basic_string_view<char> fmt_str,
                      fmt::basic_format_args<fmt::context> args) {}
    LOGLEVEL GetMaxLevel()            { return LOGLEVEL_NONE; }
    bool IsConsoleOutputEnabled()     { return false; }
    bool IsFileOutputEnabled()        { return false; }
    void SetConsoleOutputLevel(LOGLEVEL) {}
    void SetFileOutputLevel(LOGLEVEL, std::string) {}
    void SetTimestampsEnabled(bool)   {}
}
