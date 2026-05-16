// BionicSX2 — FmtLogStubs.cpp
// Uses __asm__ labels with EXACT mangled names derived from linker error messages.
// libc++ ABI: std::__1:: namespace (Apple clang on macOS/iOS).

#include <cstdint>
#include <cstddef>
#include <cstdarg>

// ════════════════════════════════════════════════════════════════════════════
// STRATEGY: define stub bodies with unique internal names, then export them
// under the exact C++ mangled names the linker expects.
// No headers needed — we never call these functions, just satisfy the linker.
// ════════════════════════════════════════════════════════════════════════════

// ── Log::GetMaxLevel() → _ZN3Log11GetMaxLevelEv ─────────────────────────────
__attribute__((visibility("default")))
unsigned int _bionicsx2_Log_GetMaxLevel()
    __asm__("_ZN3Log11GetMaxLevelEv");
unsigned int _bionicsx2_Log_GetMaxLevel() { return 0; }

// ── Log::IsConsoleOutputEnabled() → _ZN3Log22IsConsoleOutputEnabledEv ───────
__attribute__((visibility("default")))
bool _bionicsx2_Log_IsConsoleOutputEnabled()
    __asm__("_ZN3Log22IsConsoleOutputEnabledEv");
bool _bionicsx2_Log_IsConsoleOutputEnabled() { return false; }

// ── Log::IsFileOutputEnabled() → _ZN3Log19IsFileOutputEnabledEv ─────────────
__attribute__((visibility("default")))
bool _bionicsx2_Log_IsFileOutputEnabled()
    __asm__("_ZN3Log19IsFileOutputEnabledEv");
bool _bionicsx2_Log_IsFileOutputEnabled() { return false; }

// ── Log::SetTimestampsEnabled(bool) → _ZN3Log21SetTimestampsEnabledEb ───────
__attribute__((visibility("default")))
void _bionicsx2_Log_SetTimestampsEnabled(bool)
    __asm__("_ZN3Log21SetTimestampsEnabledEb");
void _bionicsx2_Log_SetTimestampsEnabled(bool) {}

// ── Log::SetConsoleOutputLevel(LOGLEVEL) → _ZN3Log22SetConsoleOutputLevelE8LOGLEVEL
__attribute__((visibility("default")))
void _bionicsx2_Log_SetConsoleOutputLevel(unsigned int)
    __asm__("_ZN3Log22SetConsoleOutputLevelE8LOGLEVEL");
void _bionicsx2_Log_SetConsoleOutputLevel(unsigned int) {}

// ── Log::SetFileOutputLevel(LOGLEVEL, std::__1::basic_string<char,...>)
// → _ZN3Log19SetFileOutputLevelE8LOGLEVELNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEE
__attribute__((visibility("default")))
void _bionicsx2_Log_SetFileOutputLevel(unsigned int, const void*)
    __asm__("_ZN3Log19SetFileOutputLevelE8LOGLEVELNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEE");
void _bionicsx2_Log_SetFileOutputLevel(unsigned int, const void*) {}

// ── Log::Write(LOGLEVEL, ConsoleColors, std::__1::basic_string_view<char,...>)
// → _ZN3Log5WriteE8LOGLEVEL13ConsoleColorsNSt3__117basic_string_viewIcNS1_11char_traitsIcEEEE
__attribute__((visibility("default")))
void _bionicsx2_Log_Write(unsigned int, unsigned int, const void*)
    __asm__("_ZN3Log5WriteE8LOGLEVEL13ConsoleColorsNSt3__117basic_string_viewIcNS1_11char_traitsIcEEEE");
void _bionicsx2_Log_Write(unsigned int, unsigned int, const void*) {}

// ── Log::Writev(LOGLEVEL, ConsoleColors, char const*, char*)
// → _ZN3Log6WritevE8LOGLEVEL13ConsoleColorsPKcPc
__attribute__((visibility("default")))
void _bionicsx2_Log_Writev(unsigned int, unsigned int, const char*, char*)
    __asm__("_ZN3Log6WritevE8LOGLEVEL13ConsoleColorsPKcPc");
void _bionicsx2_Log_Writev(unsigned int, unsigned int, const char*, char*) {}

// ── Log::WriteFmtArgs(LOGLEVEL, ConsoleColors, fmt::v12::basic_string_view<char>,
//                     fmt::v12::basic_format_args<fmt::v12::context>)
// → _ZN3Log12WriteFmtArgsE8LOGLEVEL13ConsoleColorsN3fmt3v1217basic_string_viewIcEENS3_20basic_format_argsINS3_7contextEEE
__attribute__((visibility("default")))
void _bionicsx2_Log_WriteFmtArgs(unsigned int, unsigned int, const void*, const void*)
    __asm__("_ZN3Log12WriteFmtArgsE8LOGLEVEL13ConsoleColorsN3fmt3v1217basic_string_viewIcEENS3_20basic_format_argsINS3_7contextEEE");
void _bionicsx2_Log_WriteFmtArgs(unsigned int, unsigned int, const void*, const void*) {}

// NOTE: fmt::v12 stubs removed — real format.cc is compiled into
// both libBionicSX2.a and BionicSX2_App, providing real definitions.
