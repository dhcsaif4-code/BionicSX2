// BionicSX2 iOS Port — MissingSymbols.mm
// AUDIT REFERENCE: Phase 0-A, Sections 2.3-ADDENDUM, 13.7
// STATUS: YELLOW — stubs for iOS dead-code paths only
// NO PrecompiledHeader.h — this file belongs to BionicSX2_App target, not pcsx2 core

#import <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <string>
#include <vector>
#include <memory>
#include <functional>

// ════════════════════════════════════════════════════════════════════════════
// GROUP A — RGBA8Image
// ════════════════════════════════════════════════════════════════════════════
struct RGBA8Image {
    RGBA8Image();
    RGBA8Image(RGBA8Image&&);
    ~RGBA8Image();
    bool LoadFromBuffer(const char* filename, const void* data, size_t data_size);
};
RGBA8Image::RGBA8Image()  {}
RGBA8Image::RGBA8Image(RGBA8Image&&) {}
RGBA8Image::~RGBA8Image() {}
bool RGBA8Image::LoadFromBuffer(const char*, const void*, size_t) { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP B — isa_native::GSDrawScanline  (SW rasterizer stubs — Metal only on iOS)
// ════════════════════════════════════════════════════════════════════════════
struct GSVector4i;
struct GSVertexSW;
struct GSScanlineLocalData;
struct GSRasterizerData;

namespace isa_native {
  struct GSDrawScanline {
    GSDrawScanline();
    ~GSDrawScanline();
    void PrintStats();
    void ResetCodeCache();
    void BeginDraw(const GSRasterizerData&, GSScanlineLocalData&);
    void SetupDraw(GSRasterizerData&);
    void DrawRect(const GSVector4i&, const GSVertexSW&, GSScanlineLocalData&);
  };
  GSDrawScanline::GSDrawScanline()  {}
  GSDrawScanline::~GSDrawScanline() {}
  void GSDrawScanline::PrintStats()    {}
  void GSDrawScanline::ResetCodeCache() {}
  void GSDrawScanline::BeginDraw(const GSRasterizerData&, GSScanlineLocalData&) {}
  void GSDrawScanline::SetupDraw(GSRasterizerData&) {}
  void GSDrawScanline::DrawRect(const GSVector4i&, const GSVertexSW&, GSScanlineLocalData&) {}
}

// ════════════════════════════════════════════════════════════════════════════
// GROUP C — AudioStream backends (Cubeb + SDL — unavailable on iOS)
// ════════════════════════════════════════════════════════════════════════════
struct AudioStreamParameters;
struct Error;
enum class AudioBackend : uint8_t;

struct AudioStream {
  static std::vector<std::string> GetCubebDriverNames();
  static std::vector<std::string> GetCubebOutputDevices(const char*);
  static std::unique_ptr<AudioStream> CreateCubebAudioStream(
      uint32_t, const AudioStreamParameters&, const char*, const char*, bool, Error*);
  static std::unique_ptr<AudioStream> CreateSDLAudioStream(
      uint32_t, const AudioStreamParameters&, bool, Error*);
  virtual ~AudioStream() {}
};
std::vector<std::string> AudioStream::GetCubebDriverNames() { return {}; }
std::vector<std::string> AudioStream::GetCubebOutputDevices(const char*) { return {}; }
std::unique_ptr<AudioStream> AudioStream::CreateCubebAudioStream(
    uint32_t, const AudioStreamParameters&, const char*, const char*, bool, Error*) { return nullptr; }
std::unique_ptr<AudioStream> AudioStream::CreateSDLAudioStream(
    uint32_t, const AudioStreamParameters&, bool, Error*) { return nullptr; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP D — SaveStateBase::vuJITFreeze  (JIT freeze — interpreter only on iOS)
// ════════════════════════════════════════════════════════════════════════════
struct SaveStateBase {
  void vuJITFreeze();
};
void SaveStateBase::vuJITFreeze() {}

// ════════════════════════════════════════════════════════════════════════════
// GROUP E — HTTPDownloader::Create
// ════════════════════════════════════════════════════════════════════════════
struct HTTPDownloader {
  static std::unique_ptr<HTTPDownloader> Create(std::string);
  virtual ~HTTPDownloader() {}
};
std::unique_ptr<HTTPDownloader> HTTPDownloader::Create(std::string) { return nullptr; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP F — SDLInputSource  (SDL input — replaced by GameController.framework)
// ════════════════════════════════════════════════════════════════════════════
struct SettingsInterface;
struct SDLInputSource {
  SDLInputSource();
  void ResetRGBForAllPlayers(SettingsInterface&);
};
SDLInputSource::SDLInputSource() {}
void SDLInputSource::ResetRGBForAllPlayers(SettingsInterface&) {}

// ════════════════════════════════════════════════════════════════════════════
// GROUP G — MemoryInterface IdempotentWrite
// ════════════════════════════════════════════════════════════════════════════
struct MemoryInterface {
  void IdempotentWrite8(uint32_t, uint8_t);
  void IdempotentWrite16(uint32_t, uint16_t);
  void IdempotentWrite32(uint32_t, uint32_t);
  void IdempotentWrite64(uint32_t, uint64_t);
  void IdempotentWriteBytes(uint32_t, void*, uint32_t);
  template<typename T> bool IdempotentWrite(uint32_t, T);
};
void MemoryInterface::IdempotentWrite8(uint32_t, uint8_t)    {}
void MemoryInterface::IdempotentWrite16(uint32_t, uint16_t)  {}
void MemoryInterface::IdempotentWrite32(uint32_t, uint32_t)  {}
void MemoryInterface::IdempotentWrite64(uint32_t, uint64_t)  {}
void MemoryInterface::IdempotentWriteBytes(uint32_t, void*, uint32_t) {}
template<> bool MemoryInterface::IdempotentWrite<uint8_t>(uint32_t, uint8_t) { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP H — FolderMemoryCard + FolderMemoryCardAggregator
// ════════════════════════════════════════════════════════════════════════════
struct McdSizeInfo;
namespace Pcsx2Config { struct McdOptions {}; struct GSOptions {}; }

struct FileAccessHelper { ~FileAccessHelper(); };
FileAccessHelper::~FileAccessHelper() {}

struct FolderMemoryCard {
  FolderMemoryCard();
  bool IsFormatted() const;
  bool Open(std::string, const Pcsx2Config::McdOptions&, uint32_t, bool, std::string, bool);
  void Close(bool);
};
FolderMemoryCard::FolderMemoryCard() {}
bool FolderMemoryCard::IsFormatted() const { return false; }
bool FolderMemoryCard::Open(std::string, const Pcsx2Config::McdOptions&, uint32_t, bool, std::string, bool) { return false; }
void FolderMemoryCard::Close(bool) {}

struct FolderMemoryCardAggregator {
  FolderMemoryCardAggregator();
  void Open(); void Close(); void SetFiltering(bool);
  bool IsPresent(uint32_t); bool IsPSX(uint32_t);
  uint64_t GetCRC(uint32_t);
  void GetSizeInfo(uint32_t, McdSizeInfo&);
  bool Read(uint32_t, uint8_t*, uint32_t, int);
  bool Save(uint32_t, const uint8_t*, uint32_t, int);
  bool EraseBlock(uint32_t, uint32_t);
  void NextFrame(uint32_t);
  bool ReIndex(uint32_t, bool, const std::string&);
};
FolderMemoryCardAggregator::FolderMemoryCardAggregator() {}
void FolderMemoryCardAggregator::Open()  {}
void FolderMemoryCardAggregator::Close() {}
void FolderMemoryCardAggregator::SetFiltering(bool) {}
bool FolderMemoryCardAggregator::IsPresent(uint32_t) { return false; }
bool FolderMemoryCardAggregator::IsPSX(uint32_t)     { return false; }
uint64_t FolderMemoryCardAggregator::GetCRC(uint32_t) { return 0; }
void FolderMemoryCardAggregator::GetSizeInfo(uint32_t, McdSizeInfo&) {}
bool FolderMemoryCardAggregator::Read(uint32_t, uint8_t*, uint32_t, int)        { return false; }
bool FolderMemoryCardAggregator::Save(uint32_t, const uint8_t*, uint32_t, int)  { return false; }
bool FolderMemoryCardAggregator::EraseBlock(uint32_t, uint32_t) { return false; }
void FolderMemoryCardAggregator::NextFrame(uint32_t) {}
bool FolderMemoryCardAggregator::ReIndex(uint32_t, bool, const std::string&) { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP I — IOCtlSrc  (physical disc ioctl — no drive on iOS)
// ════════════════════════════════════════════════════════════════════════════
struct cdvdSubQ;
struct IOCtlSrc {
  IOCtlSrc(std::string);
  ~IOCtlSrc();
  bool Reopen(Error*);
  bool DiscReady();
  int  GetMediaType() const;
  uint32_t GetSectorCount() const;
  uint32_t GetLayerBreakAddress() const;
  bool ReadTOC() const;
  bool ReadTrackSubQ(cdvdSubQ*) const;
  bool ReadSectors2048(uint32_t, uint32_t, uint8_t*) const;
  bool ReadSectors2352(uint32_t, uint32_t, uint8_t*) const;
};
IOCtlSrc::IOCtlSrc(std::string)  {}
IOCtlSrc::~IOCtlSrc() {}
bool IOCtlSrc::Reopen(Error*)    { return false; }
bool IOCtlSrc::DiscReady()       { return false; }
int  IOCtlSrc::GetMediaType() const       { return -1; }
uint32_t IOCtlSrc::GetSectorCount() const  { return 0; }
uint32_t IOCtlSrc::GetLayerBreakAddress() const { return 0; }
bool IOCtlSrc::ReadTOC() const               { return false; }
bool IOCtlSrc::ReadTrackSubQ(cdvdSubQ*) const { return false; }
bool IOCtlSrc::ReadSectors2048(uint32_t, uint32_t, uint8_t*) const { return false; }
bool IOCtlSrc::ReadSectors2352(uint32_t, uint32_t, uint8_t*) const { return false; }

// ════════════════════════════════════════════════════════════════════════════
// GROUP J — Threading::WorkSema
// ════════════════════════════════════════════════════════════════════════════
namespace Threading {
  struct WorkSema {
    void WaitForWork();
    void WaitForWorkWithSpin();
    void WaitForEmpty();
    void WaitForEmptyWithSpin();
    bool CheckForWork();
    void Kill();
    void Reset();
  };
  void WorkSema::WaitForWork()          {}
  void WorkSema::WaitForWorkWithSpin()  {}
  void WorkSema::WaitForEmpty()         {}
  void WorkSema::WaitForEmptyWithSpin() {}
  bool WorkSema::CheckForWork()         { return false; }
  void WorkSema::Kill()                 {}
  void WorkSema::Reset()                {}
}

// ════════════════════════════════════════════════════════════════════════════
// GROUP K — GameDatabaseSchema::GameEntry
// ════════════════════════════════════════════════════════════════════════════
struct Patch;

namespace GameDatabaseSchema {
  struct GameEntry {
    void applyGameFixes(::Pcsx2Config::McdOptions&, bool) const;
    void applyGSHardwareFixes(::Pcsx2Config::GSOptions&) const;
    std::string memcardFiltersAsString() const;
    const Patch* findPatch(uint32_t) const;
  };
  void GameEntry::applyGameFixes(::Pcsx2Config::McdOptions&, bool) const {}
  void GameEntry::applyGSHardwareFixes(::Pcsx2Config::GSOptions&) const {}
  std::string GameEntry::memcardFiltersAsString() const { return {}; }
  const Patch* GameEntry::findPatch(uint32_t) const { return nullptr; }
}

// ════════════════════════════════════════════════════════════════════════════
// GROUP L — Host callbacks
// ════════════════════════════════════════════════════════════════════════════
namespace Achievements { enum class LoginRequestReason : uint8_t { User, Token, Runtime }; }
namespace Host {
  void OnAchievementsLoginRequested(Achievements::LoginRequestReason) {}
}
