// BionicSX2 — FmtLogStubs.cpp
// Strategy: define stub functions then alias them to the exact
// mangled names the linker expects using __asm__ labels.
// This bypasses all fmt ABI/header-only confusion.

#include <cstdint>
#include <cstddef>
#include <string>
#include <locale>
#include <cstdarg>

// ─── fmt::v12 stubs via asm aliases ─────────────────────────────────────────
// Mangled names from: nm libBionicSX2.a | grep " U .*fmt"

// fmt::v12::vformat(fmt::v12::basic_string_view<char>, fmt::v12::basic_format_args<fmt::v12::context>)
__attribute__((visibility("default")))
std::string bionicsx2_fmt_vformat(const void*, const void*)
  __asm__("_ZN3fmt3v126vformatENS0_17basic_string_viewIcEENS0_20basic_format_argsINS0_7contextEEE");
std::string bionicsx2_fmt_vformat(const void*, const void*) { return {}; }

// fmt::v12::detail::vformat_to(fmt::v12::detail::buffer<char>&, ...)
__attribute__((visibility("default")))
void bionicsx2_fmt_vformat_to(void*, const void*, const void*, const void*)
  __asm__("_ZN3fmt3v126detail10vformat_toIcEEvRNS1_6bufferIT_EENS0_17basic_string_viewIS3_EENS0_20basic_format_argsINS0_7contextEEENS0_10locale_refE");
void bionicsx2_fmt_vformat_to(void*, const void*, const void*, const void*) {}

// fmt::v12::report_error(char const*)
__attribute__((visibility("default")))
void bionicsx2_fmt_report_error(const char*)
  __asm__("_ZN3fmt3v1212report_errorEPKc");
void bionicsx2_fmt_report_error(const char*) {}

// fmt::v12::detail::is_printable(unsigned int)
__attribute__((visibility("default")))
bool bionicsx2_fmt_is_printable(unsigned int)
  __asm__("_ZN3fmt3v126detail12is_printableEj");
bool bionicsx2_fmt_is_printable(unsigned int) { return true; }

// std::locale fmt::v12::locale_ref::get<std::locale>() const
__attribute__((visibility("default")))
void* bionicsx2_fmt_locale_ref_get()
  __asm__("_ZNK3fmt3v1210locale_ref3getISt6localeEET_v");
void* bionicsx2_fmt_locale_ref_get() { return nullptr; }

// ─── Log stubs via asm aliases ───────────────────────────────────────────────
// We use raw asm names because LOGLEVEL/ConsoleColors enum ABI must match

// Log::WriteFmtArgs(LOGLEVEL, ConsoleColors, fmt::v12::basic_string_view<char>, fmt::v12::basic_format_args<fmt::v12::context>)
__attribute__((visibility("default")))
void bionicsx2_log_WriteFmtArgs(unsigned int, unsigned int, const void*, const void*)
  __asm__("_ZN3Log12WriteFmtArgsE8LOGLEVEL13ConsoleColorsN3fmt3v1217basic_string_viewIcEENS3_20basic_format_argsINS3_7contextEEE");
void bionicsx2_log_WriteFmtArgs(unsigned int, unsigned int, const void*, const void*) {}

// Log::Write(LOGLEVEL, ConsoleColors, std::string_view)
__attribute__((visibility("default")))
void bionicsx2_log_Write(unsigned int, unsigned int, const void*)
  __asm__("_ZN3Log5WriteE8LOGLEVEL13ConsoleColorsSt17basic_string_viewIcSt11char_traitsIcEE");
void bionicsx2_log_Write(unsigned int, unsigned int, const void*) {}

// Log::Writev(LOGLEVEL, ConsoleColors, char const*, char*)
__attribute__((visibility("default")))
void bionicsx2_log_Writev(unsigned int, unsigned int, const char*, char*)
  __asm__("_ZN3Log6WritevE8LOGLEVEL13ConsoleColorsPKcPc");
void bionicsx2_log_Writev(unsigned int, unsigned int, const char*, char*) {}

// Log::GetMaxLevel()
__attribute__((visibility("default")))
unsigned int bionicsx2_log_GetMaxLevel()
  __asm__("_ZN3Log11GetMaxLevelEv");
unsigned int bionicsx2_log_GetMaxLevel() { return 0; }

// Log::IsConsoleOutputEnabled()
__attribute__((visibility("default")))
bool bionicsx2_log_IsConsoleEnabled()
  __asm__("_ZN3Log22IsConsoleOutputEnabledEv");
bool bionicsx2_log_IsConsoleEnabled() { return false; }

// Log::IsFileOutputEnabled()
__attribute__((visibility("default")))
bool bionicsx2_log_IsFileEnabled()
  __asm__("_ZN3Log19IsFileOutputEnabledEv");
bool bionicsx2_log_IsFileEnabled() { return false; }

// Log::SetConsoleOutputLevel(LOGLEVEL)
__attribute__((visibility("default")))
void bionicsx2_log_SetConsoleLevel(unsigned int)
  __asm__("_ZN3Log22SetConsoleOutputLevelE8LOGLEVEL");
void bionicsx2_log_SetConsoleLevel(unsigned int) {}

// Log::SetFileOutputLevel(LOGLEVEL, std::string)
__attribute__((visibility("default")))
void bionicsx2_log_SetFileLevel(unsigned int, const void*)
  __asm__("_ZN3Log19SetFileOutputLevelE8LOGLEVELNSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEE");
void bionicsx2_log_SetFileLevel(unsigned int, const void*) {}

// Log::SetTimestampsEnabled(bool)
__attribute__((visibility("default")))
void bionicsx2_log_SetTimestamps(bool)
  __asm__("_ZN3Log21SetTimestampsEnabledEb");
void bionicsx2_log_SetTimestamps(bool) {}
