// BionicSX2 — FmtLogStubs.cpp
// fmt is header-only in this build (FMT_FUNC = inline).
// All fmt symbols are already inlined into libBionicSX2.a.
// We only need to stub Log:: functions using the real fmt types.

#define FMT_HEADER_ONLY 1
#include "../../3rdparty/fmt/include/fmt/format.h"

#include <string>
#include <string_view>
#include <cstdarg>

enum LOGLEVEL : unsigned int {
    LOGLEVEL_NONE=0, LOGLEVEL_ERROR, LOGLEVEL_WARNING, LOGLEVEL_PERF,
    LOGLEVEL_INFO, LOGLEVEL_VERBOSE, LOGLEVEL_DEV, LOGLEVEL_DEBUG,
    LOGLEVEL_TRACE, LOGLEVEL_BULK
};
enum ConsoleColors : unsigned int { Color_Default=0 };

namespace Log {
    void Write(LOGLEVEL, ConsoleColors, std::string_view) {}
    void Writev(LOGLEVEL, ConsoleColors, const char*, char*) {}
    void WriteFmtArgs(LOGLEVEL,
                      ConsoleColors,
                      fmt::basic_string_view<char>,
                      fmt::basic_format_args<fmt::context>) {}
    LOGLEVEL GetMaxLevel()            { return LOGLEVEL_NONE; }
    bool IsConsoleOutputEnabled()     { return false; }
    bool IsFileOutputEnabled()        { return false; }
    void SetConsoleOutputLevel(LOGLEVEL) {}
    void SetFileOutputLevel(LOGLEVEL, std::string) {}
    void SetTimestampsEnabled(bool)   {}
}
