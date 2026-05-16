// SymbolStubs.cpp — iOS stub implementations
// All mangled names verified from nm on macOS CI runner

#include <string>
#include <string_view>
#include <cstdarg>

// ── LOGLEVEL / ConsoleColors (match pcsx2 enums exactly) ─────────────────────
enum LOGLEVEL : unsigned char { LOGLEVEL_NONE = 0, LOGLEVEL_ERROR, LOGLEVEL_WARNING,
                     LOGLEVEL_PERF, LOGLEVEL_INFO, LOGLEVEL_VERBOSE,
                     LOGLEVEL_DEBUG, LOGLEVEL_TRACE, LOGLEVEL_COUNT };
enum ConsoleColors : int { Color_Default = 0 };

// ── fmt forward declarations (match fmt::v12 ABI) ────────────────────────────
namespace fmt { namespace v12 {
  template<typename Char> struct basic_string_view {
    const Char* _ptr = nullptr;
    std::size_t _size = 0;
  };
  struct context {};
  template<typename Ctx> struct basic_format_args {
    const void* _data = nullptr;
    int _size = 0;
  };
}}

// ── Log:: namespace stubs ────────────────────────────────────────────────────
namespace Log {
  LOGLEVEL GetMaxLevel() { return LOGLEVEL_NONE; }
  bool IsConsoleOutputEnabled() { return false; }
  bool IsFileOutputEnabled()    { return false; }
  void SetConsoleOutputLevel(LOGLEVEL) {}
  void SetFileOutputLevel(LOGLEVEL, std::string) {}
  void SetTimestampsEnabled(bool) {}
  void Write(LOGLEVEL, ConsoleColors, std::string_view) {}
  void Writev(LOGLEVEL, ConsoleColors, const char*, char*) {}
  void WriteFmtArgs(LOGLEVEL, ConsoleColors,
    fmt::v12::basic_string_view<char>,
    fmt::v12::basic_format_args<fmt::v12::context>) {}
}

// ── GSDrawScanline + GameDatabaseSchema ──────────────────
// Structs must be defined inside isa_native namespace
// so NS_ back-reference in mangled name is correct

// Global structs must be declared BEFORE isa_native uses them
struct GSVector4i {};
struct GSVertexSW {};

namespace isa_native {

  struct GSScanlineLocalData {};
  struct GSRasterizerData {};

  struct GSDrawScanline {
    GSDrawScanline()  {}
    ~GSDrawScanline() {}
    void BeginDraw(const GSRasterizerData&, GSScanlineLocalData&) {}
    void SetupDraw(GSRasterizerData&) {}
    void DrawRect(const ::GSVector4i&, const ::GSVertexSW&, GSScanlineLocalData&) {}
    void PrintStats() {}
    void ResetCodeCache() {}
  };

} // namespace isa_native

// GameDatabaseSchema — global namespace
struct Pcsx2Config {};
namespace GameDatabaseSchema {
  struct GameEntry {
    void applyGameFixes(Pcsx2Config&, bool) const {}
  };
}
