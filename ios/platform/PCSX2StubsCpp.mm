// AUDIT REFERENCE: Phase 0 (Categories 3-9) — C++ namespace stubs
// STATUS: NEW
// These must match the exact declarations from PCSX2 headers.
#include "common/CocoaTools.h"
#include "common/Darwin/DarwinMisc.h"
#include "GS/Renderers/SW/GSRendererSW.h"
#include "GS/GSState.h"
#include "GS/Renderers/Common/GSVertexTrace.h"
#include "SaveState.h"
#include "Recording/InputRecording.h"
#include "DebugTools/Breakpoints.h"
#include "DebugTools/SymbolGuardian.h"
#include "Host/AudioStream.h"
#include "Input/InputManager.h"
#include "GSDumpReplayer.h"
#include <string>
#include <vector>

// Category 4: SW Renderer dispatch stubs (Audit Sec 2.2)
namespace isa_native {
    std::unique_ptr<GSRendererSW> makeGSRendererSW(int threads) { return nullptr; }
    void GSVertexTracePopulateFunctions(GSVertexTrace&) {}
}
void GSVertexSW::InitStatic() {}

// CocoaTools stubs
namespace CocoaTools {
    std::optional<std::string> GetNonTranslocatedBundlePath() { return std::nullopt; }
}

// DarwinMisc stubs
std::vector<DarwinMisc::CPUClass> DarwinMisc::GetCPUClasses() { return {}; }

// GameDatabase stub (minimal)
// No game database on iOS

// SaveState stubs
bool SaveState_SaveScreenshot(const std::string&, const void*, u32) { return false; }
bool DownloadState(const std::string&, std::vector<u8>*) { return false; }
bool UnzipFromDisk(const std::string&, const std::string&) { return false; }
bool SaveState_ZipToDisk(const std::string&, const std::string&) { return false; }
void ReportLoadErrorOSD(const std::string&, int) {}
void ReportSaveErrorOSD(const std::string&, int) {}

// InputRecording stubs
namespace InputRecording { void SetActive(bool) {} bool IsActive() { return false; } }

// CBreakPoints stubs
namespace CBreakPoints {
    void AddBreakPoint(u32, bool) {}
    void RemoveBreakPoint(u32) {}
    bool IsBreakPoint(u32) { return false; }
    void AddMemCheck(u32, u32, int, int) {}
    void RemoveMemCheck(u32) {}
    void ClearAllBreakPoints() {}
    void ClearAllMemChecks() {}
}

// SymbolGuardian stubs
namespace SymbolGuardian {
    bool LoadSymbolFile(const std::string&) { return false; }
    void UnloadSymbolFile() {}
}

// AudioStream stubs
std::unique_ptr<AudioStream> AudioStream::CreateCubebAudioStream() { return nullptr; }
std::unique_ptr<AudioStream> AudioStream::CreateSDLAudioStream() { return nullptr; }
std::vector<std::string> AudioStream::GetCubebDriverNames() { return {}; }
std::vector<std::string> AudioStream::GetCubebOutputDevices() { return {}; }

// InputManager stubs
std::optional<std::vector<u32>> InputManager::ConvertHostKeyboardStringToCode(const std::string_view&) { return std::nullopt; }
std::string InputManager::ConvertHostKeyboardCodeToString(u32) { return {}; }
std::string InputManager::ConvertHostKeyboardCodeToIcon(u32) { return {}; }

// Misc stubs
BiosInformation CurrentBiosInformation = {};
void ReadOSDConfigParames() {}
std::string ShiftJIS_ConvertString(const std::string& s) { return s; }
std::vector<std::string> GetMetalAdapterList() { return {}; }
int DebugInterface::parseExpression(const std::string&) { return 0; }
u32 standardizeBreakpointAddress(u32 addr) { return addr; }
namespace GSDumpReplayer { bool IsReplayingDump() { return false; } void LoadDump(const std::string&) {} }
