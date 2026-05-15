// AUDIT REFERENCE: Phase 0 (Categories 1–9)
// STATUS: NEW
#import <Foundation/Foundation.h>
#include "PrecompiledHeader.h"
#include "common/Assertions.h"
#include "common/CocoaTools.h"
#include "common/Darwin/DarwinMisc.h"
#include "common/Threading.h"
#include "common/HostSys.h"
#include "GS/GS.h"
#include "GS/Renderers/SW/GSRendererSW.h"
#include "GS/GSState.h"
#include "GS/Renderers/Common/GSVertexTrace.h"
#include "GameDatabase.h"
#include "Host/AudioStream.h"
#include "Input/InputManager.h"
#include "DebugTools/DebugInterface.h"
#include "SaveState.h"
#include "R5900OpcodeTables.h"
#include "Recording/InputRecording.h"
#include "DebugTools/Breakpoints.h"
#include "DebugTools/SymbolGuardian.h"
#include "GSDumpReplayer.h"

// AUDIT: VifUnpackSSE_Init forced no-op for iOS (Phase 0-B)
void VifUnpackSSE_Init() {}
void vtlb_DynBackpatchLoadStore(uptr, u32, u32, u32, u8, u8, u8, bool, bool, bool) {}

// Category 4: SW Renderer dispatch stubs (Audit Sec 2.2)
namespace isa_native {
    std::unique_ptr<GSRendererSW> makeGSRendererSW(int threads) { return nullptr; }
    void GSVertexTracePopulateFunctions(GSVertexTrace&) {}
}
void GSVertexSW::InitStatic() {}

// Category 5: ImGui stubs (Audit Sec 0-F)
namespace ImGuiManager { bool Initialize() { return true; } void Shutdown() {} }
namespace ImGuiFullscreen { bool IsInitialized() { return false; } void OpenPauseMenu() {} }

// Category 6: FullscreenUI stubs (Audit Sec 0-F)
namespace FullscreenUI { bool IsInitialized() { return false; } void Initialize() {} void Shutdown() {} void OpenPauseMenu() {} bool HasPlatformLayer() { return false; } }

// Category 8: DEV9 stubs
void smap_async(void*, int) {}
u32 smap_read8(u32) { return 0; }
u32 smap_read16(u32) { return 0; }
u32 smap_read32(u32) { return 0; }
void smap_write8(u32, u32) {}
void smap_write16(u32, u32) {}
void smap_write32(u32, u32) {}
void smap_readDMA8Mem(u32, u32) {}
void smap_writeDMA8Mem(u32, u32) {}
u32 FLASHread32(u32) { return 0; }
void FLASHwrite32(u32, u32) {}
void FLASHinit() {}
void InitNet() {}
void TermNet() {}
void ReconfigureLiveNet() {}

// USB stubs
void ohci_async_service_poll(void*, bool) {}
void ohci_set_a(void*, void*) {}
void ohci_put_a(void*, void*) {}
u32 usb_read8(u32 addr) { return 0; }
u32 usb_read16(u32 addr) { return 0; }
u32 usb_read32(u32 addr) { return 0; }
void usb_write8(u32 addr, u32 val) {}
void usb_write16(u32 addr, u32 val) {}
void usb_write32(u32 addr, u32 val) {}
const char* usb_desc_parse(const u8* data, int len, const char* callback, void* opaque, int* result) { return nullptr; }

// PGIF stubs
void PGIFrQword(u32, u32) {}
void PGIFwQword(u32, u32) {}
u32 PGIFr(u32 addr) { return 0; }
u32 PGIFw(u32 addr, u32 val) { return 0; }
void pgifInit() {}

// FIFO stubs
void ReadFifoSingleWord(void*, void*) {}
void ReadFIFO_VIF1(void*, void*) {}
void WriteFIFO_VIF0(void*, void*) {}
void WriteFIFO_VIF1(void*, void*) {}
void WriteFIFO_GIF(void*, void*) {}
void sifReset() {}
void SIF1Dma() {}
void dmaSIF1() {}
void dmaSIF2() {}
void EEsif1Interrupt() {}
void sif1Interrupt() {}
void sif2Interrupt() {}
void dVifRelease(int) {}
void dVifReset(int) {}

// CDR stubs (Category 3)
u32 cdrRead0(u32 addr) { return 0; }
u32 cdrRead1(u32 addr) { return 0; }
u32 cdrRead2(u32 addr) { return 0; }
u32 cdrRead3(u32 addr) { return 0; }
void cdrWrite0(u32 addr, u32 val) {}
void cdrWrite1(u32 addr, u32 val) {}
void cdrWrite2(u32 addr, u32 val) {}
void cdrWrite3(u32 addr, u32 val) {}
void cdrReset() {}
void cdrInterrupt() {}
void cdrReadInterrupt() {}

// IPU stubs (Category 3)
u32 ipuRead32(u32 addr) { return 0; }
u64 ipuRead64(u32 addr) { return 0; }
void ipuWrite32(u32 addr, u32 val) {}
void ipuWrite64(u32 addr, u64 val) {}
void ipuReset() {}
void ipu0Interrupt() {}
void ipu1Interrupt() {}
void ipuCMDProcess(int, u32) {}
void dmaIPU0() {}
void dmaIPU1() {}
void ReadFIFO_IPUout(void*, void*) {}
void WriteFIFO_IPUin(void*, void*) {}

// MDEC stubs (Category 3)
u32 mdecRead0(u32 addr) { return 0; }
u32 mdecRead1(u32 addr) { return 0; }
void mdecWrite0(u32 addr, u32 val) {}
void mdecWrite1(u32 addr, u32 val) {}
void mdecInit() {}

// Cache stubs (Category 3)
void readCache8(u32, u32*) {}
void readCache16(u32, u32*) {}
void readCache32(u32, u32*) {}
void readCache64(u32, u32*) {}
void readCache128(u32, u32*) {}
void writeCache8(u32, u32) {}
void writeCache16(u32, u32) {}
void writeCache32(u32, u32) {}
void writeCache64(u32, u64) {}
void writeCache128(u32, u128) {}
void writebackCache(u32, u32) {}

// BIOS stubs
void CopyBIOSToMemory() {}

// Category 9: Misc required stubs
std::optional<std::string> CocoaTools::GetNonTranslocatedBundlePath() { return CocoaTools::GetBundlePath(); }
std::vector<DarwinMisc::CPUClass> DarwinMisc::GetCPUClasses() { return {}; }
const GameDatabase::Game* GameDatabase::findGame(const std::string_view&) { return nullptr; }
bool SaveState_SaveScreenshot(const std::string&, const void*, u32) { return false; }
bool DownloadState(const std::string&, std::vector<u8>*) { return false; }
bool UnzipFromDisk(const std::string&, const std::string&) { return false; }
bool SaveState_ZipToDisk(const std::string&, const std::string&) { return false; }
void ReportLoadErrorOSD(const std::string&, int) {}
void ReportSaveErrorOSD(const std::string&, int) {}
namespace InputRecording { void SetActive(bool) {} bool IsActive() { return false; } }

namespace CBreakPoints {
    void AddBreakPoint(u32, bool) {}
    void RemoveBreakPoint(u32) {}
    bool IsBreakPoint(u32) { return false; }
    void AddMemCheck(u32, u32, int, int) {}
    void RemoveMemCheck(u32) {}
    void ClearAllBreakPoints() {}
    void ClearAllMemChecks() {}
}

namespace SymbolGuardian {
    bool LoadSymbolFile(const std::string&) { return false; }
    void UnloadSymbolFile() {}
}

BiosInformation CurrentBiosInformation = {};
void ReadOSDConfigParames() {}
std::string ShiftJIS_ConvertString(const std::string& s) { return s; }
std::vector<std::string> GetMetalAdapterList() { return {}; }
std::unique_ptr<AudioStream> AudioStream::CreateCubebAudioStream() { return nullptr; }
std::unique_ptr<AudioStream> AudioStream::CreateSDLAudioStream() { return nullptr; }
std::vector<std::string> AudioStream::GetCubebDriverNames() { return {}; }
std::vector<std::string> AudioStream::GetCubebOutputDevices() { return {}; }
std::optional<std::vector<u32>> InputManager::ConvertHostKeyboardStringToCode(const std::string_view&) { return std::nullopt; }
std::string InputManager::ConvertHostKeyboardCodeToString(u32) { return {}; }
std::string InputManager::ConvertHostKeyboardCodeToIcon(u32) { return {}; }
int DebugInterface::parseExpression(const std::string&) { return 0; }
u32 standardizeBreakpointAddress(u32 addr) { return addr; }
namespace GSDumpReplayer { bool IsReplayingDump() { return false; } void LoadDump(const std::string&) {} }
