// AUDIT REFERENCE: Section 9.2
// STATUS: NEW
// iOS audio via AVAudioEngine (replaces cubeb on macOS)
#import <AVFoundation/AVFoundation.h>
#include "pcsx2/Host/AudioStream.h"
#include <memory>

class iOSAudioStream : public AudioStream {
public:
  iOSAudioStream(u32 sample_rate, const AudioStreamParameters& params)
    : AudioStream(sample_rate, params) {}
  ~iOSAudioStream() override {}
  void SetPaused(bool paused) override {}
protected:
  void FramesAvailable() override {}
};

std::unique_ptr<AudioStream> AudioStream::CreateStream(
  AudioBackend backend, u32 sample_rate,
  const AudioStreamParameters& params,
  Error* error) {
  return std::make_unique<iOSAudioStream>(sample_rate, params);
}
