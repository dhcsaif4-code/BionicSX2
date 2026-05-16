// BionicSX2 iOS Port — MissingSymbols.mm
// AUDIT REFERENCE: Phase 0-A, Sections 2.3-ADDENDUM, 13.7
// STATUS: YELLOW — all stubs for iOS dead-code paths

#include <stdint.h>
#include <stddef.h>
#include <string>
#include <vector>
#include <memory>

#import <Foundation/Foundation.h>
#include <functional>

// ─── Forward declarations ───────────────────────────────────────────────────
struct Error;
struct McdSizeInfo;
struct cdvdSubQ;
struct cdvdTD;
struct Pcsx2Config;
namespace Pcsx2Config { struct McdOptions; struct GSOptions; }
struct SettingsInterface;
struct ProgressCallback;
struct AudioStreamParameters;
enum class AudioBackend : uint8_t;
enum class Achievements { enum LoginRequestReason : uint8_t; };
struct rc_client_t;

// ════════════════════════════════════════════════════════════════════════════
// GROUP A — RGBA8Image
// ════════════════════════════════════════════════════════════════════════════
#include "common/Image.h"

RGBA8Image::RGBA8Image() = default;
RGBA8Image::RGBA8Image(RGBA8Image&&) = default;
bool RGBA8Image::LoadFromBuffer(const char* filename, const void* data, size_t data_size) { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP B — isa_native::GSDrawScanline  (SW rasterizer — dead on iOS/Metal)
// ════════════════════════════════════════════════════════════════════════════
#include "GS/Renderers/SW/GSDrawScanline.h"

namespace isa_native {
  GSDrawScanline::GSDrawScanline()  {}
  GSDrawScanline::~GSDrawScanline() {}
  void GSDrawScanline::PrintStats()   {}
  void GSDrawScanline::ResetCodeCache() {}
  void GSDrawScanline::BeginDraw(const GSRasterizerData&, GSScanlineLocalData&) {}
  void GSDrawScanline::SetupDraw(GSRasterizerData&) {}
  void GSDrawScanline::DrawRect(const GSVector4i&, const GSVertexSW&, GSScanlineLocalData&) {}
}

// ════════════════════════════════════════════════════════════════════════════
// GROUP C — AudioStream backends (Cubeb + SDL — not available on iOS)
// ════════════════════════════════════════════════════════════════════════════
#include "common/AudioStream.h"

std::vector<std::string> AudioStream::GetCubebDriverNames() { return {}; }
std::vector<std::string> AudioStream::GetCubebOutputDevices(const char*) { return {}; }
std::unique_ptr<AudioStream> AudioStream::CreateCubebAudioStream(
    uint32_t, const AudioStreamParameters&, const char*, const char*, bool, Error*) { return nullptr; }
std::unique_ptr<AudioStream> AudioStream::CreateSDLAudioStream(
    uint32_t, const AudioStreamParameters&, bool, Error*) { return nullptr; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP D — SaveStateBase::vuJITFreeze  (JIT freeze — interpreter only on iOS)
// ════════════════════════════════════════════════════════════════════════════
#include "SaveState.h"
void SaveStateBase::vuJITFreeze() {}

// ════════════════════════════════════════════════════════════════════════════
// GROUP E — HTTPDownloader::Create
// ════════════════════════════════════════════════════════════════════════════
#include "common/HTTPDownloader.h"
std::unique_ptr<HTTPDownloader> HTTPDownloader::Create(std::string) { return nullptr; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP F — SDLInputSource  (SDL input — use GameController.framework on iOS)
// ════════════════════════════════════════════════════════════════════════════
#include "SDLInputSource.h"
SDLInputSource::SDLInputSource() {}
void SDLInputSource::ResetRGBForAllPlayers(SettingsInterface&) {}

// ════════════════════════════════════════════════════════════════════════════
// GROUP G — MemoryInterface IdempotentWrite  (used by Patch.cpp)
// ════════════════════════════════════════════════════════════════════════════
#include "Patch.h"
void MemoryInterface::IdempotentWrite8(uint32_t, uint8_t)   {}
void MemoryInterface::IdempotentWrite16(uint32_t, uint16_t) {}
void MemoryInterface::IdempotentWrite32(uint32_t, uint32_t) {}
void MemoryInterface::IdempotentWrite64(uint32_t, uint64_t) {}
void MemoryInterface::IdempotentWriteBytes(uint32_t, void*, uint32_t) {}
template<> bool MemoryInterface::IdempotentWrite<uint8_t>(uint32_t, uint8_t) { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP H — FolderMemoryCard + FolderMemoryCardAggregator
// ════════════════════════════════════════════════════════════════════════════
#include "SIO/Memcard/MemoryCardFile.h"

FileAccessHelper::~FileAccessHelper() {}

FolderMemoryCard::FolderMemoryCard()  {}
bool FolderMemoryCard::IsFormatted() const { return false; }
bool FolderMemoryCard::Open(std::string, const Pcsx2Config::McdOptions&, uint32_t, bool, std::string, bool) { return false; }
void FolderMemoryCard::Close(bool) {}

FolderMemoryCardAggregator::FolderMemoryCardAggregator() {}
void FolderMemoryCardAggregator::Open()  {}
void FolderMemoryCardAggregator::Close() {}
void FolderMemoryCardAggregator::SetFiltering(bool) {}
bool FolderMemoryCardAggregator::IsPresent(uint32_t) { return false; }
bool FolderMemoryCardAggregator::IsPSX(uint32_t)     { return false; }
uint64_t FolderMemoryCardAggregator::GetCRC(uint32_t) { return 0; }
void FolderMemoryCardAggregator::GetSizeInfo(uint32_t, McdSizeInfo&) {}
bool FolderMemoryCardAggregator::Read(uint32_t, uint8_t*, uint32_t, int) { return false; }
bool FolderMemoryCardAggregator::Save(uint32_t, const uint8_t*, uint32_t, int) { return false; }
bool FolderMemoryCardAggregator::EraseBlock(uint32_t, uint32_t) { return false; }
void FolderMemoryCardAggregator::NextFrame(uint32_t) {}
bool FolderMemoryCardAggregator::ReIndex(uint32_t, bool, const std::string&) { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP I — IOCtlSrc  (disc drive ioctl — no physical drive on iOS)
// ════════════════════════════════════════════════════════════════════════════
#include "CDVD/CDVDdiscReader.h"

IOCtlSrc::IOCtlSrc(std::string)  {}
IOCtlSrc::~IOCtlSrc() {}
bool IOCtlSrc::Reopen(Error*)    { return false; }
bool IOCtlSrc::DiscReady()       { return false; }
int  IOCtlSrc::GetMediaType() const      { return -1; }
uint32_t IOCtlSrc::GetSectorCount() const { return 0; }
uint32_t IOCtlSrc::GetLayerBreakAddress() const { return 0; }
bool IOCtlSrc::ReadTOC() const              { return false; }
bool IOCtlSrc::ReadTrackSubQ(cdvdSubQ*) const { return false; }
bool IOCtlSrc::ReadSectors2048(uint32_t, uint32_t, uint8_t*) const { return false; }
bool IOCtlSrc::ReadSectors2352(uint32_t, uint32_t, uint8_t*) const { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP J — Threading::WorkSema
// ════════════════════════════════════════════════════════════════════════════
#include "common/Threading.h"

namespace Threading {
  void WorkSema::WaitForWork()         {}
  void WorkSema::WaitForWorkWithSpin() {}
  void WorkSema::WaitForEmpty()        {}
  void WorkSema::WaitForEmptyWithSpin(){}
  bool WorkSema::CheckForWork()        { return false; }
  void WorkSema::Kill()                {}
  void WorkSema::Reset()               {}
}

// ════════════════════════════════════════════════════════════════════════════
// GROUP K — GameDatabaseSchema::GameEntry
// ════════════════════════════════════════════════════════════════════════════
#include "GameDatabase.h"

namespace GameDatabaseSchema {
  void GameEntry::applyGameFixes(Pcsx2Config&, bool) const {}
  void GameEntry::applyGSHardwareFixes(Pcsx2Config::GSOptions&) const {}
  std::string GameEntry::memcardFiltersAsString() const { return {}; }
  const Patch* GameEntry::findPatch(uint32_t) const { return nullptr; }
}

// ════════════════════════════════════════════════════════════════════════════
// GROUP L — Host callbacks
// ════════════════════════════════════════════════════════════════════════════
#include "Host.h"
namespace Host {
  void OnAchievementsLoginRequested(Achievements::LoginRequestReason) {}
}
