#import <AVFoundation/AVFoundation.h>
#include "pcsx2/Host/AudioStream.h"
#include <memory>

class iOSAudioStream : public AudioStream {
public:
  iOSAudioStream(u32 sample_rate, const AudioStreamParameters& params)
    : AudioStream(sample_rate, params) {}
  ~iOSAudioStream() override {}
  void SetPaused(bool paused) override {}
};

std::unique_ptr<AudioStream> AudioStream::CreateStream(
  AudioBackend backend, u32 sample_rate,
  const AudioStreamParameters& parameters,
  const char* driver_name, const char* device_name,
  bool stretch_enabled, Error* error) {
  return std::make_unique<iOSAudioStream>(sample_rate, parameters);
}
