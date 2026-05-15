// AUDIT REFERENCE: Section 9.2
// STATUS: NEW
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <string>
#include <memory>
#include <mutex>
#include <vector>

// Configure AVAudioSession before SPU2::Init()
void iOSConfigureAudioSession() {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    if (error) NSLog(@"[BionicSX2] AVAudioSession category error: %@", error);
    [session setPreferredIOBufferDuration:0.005 error:&error]; // 5ms latency
    [session setActive:YES error:&error];
    if (error) NSLog(@"[BionicSX2] AVAudioSession activate error: %@", error);
}

// Simple ring buffer audio stream for iOS
class iOSAudioStream {
public:
    iOSAudioStream() = default;
    ~iOSAudioStream() { Close(); }

    bool Init(int sampleRate = 48000, int channels = 2) {
        std::lock_guard<std::mutex> lock(m_mutex);

        OSStatus status;

        AudioComponentDescription desc = {};
        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;

        AudioComponent component = AudioComponentFindNext(nullptr, &desc);
        if (!component) {
            NSLog(@"[BionicSX2] AudioComponentFindNext failed");
            return false;
        }

        status = AudioComponentInstanceNew(component, &m_audioUnit);
        if (status != noErr) {
            NSLog(@"[BionicSX2] AudioComponentInstanceNew failed: %d", (int)status);
            return false;
        }

        AudioStreamBasicDescription asbd = {};
        asbd.mSampleRate = sampleRate;
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
        asbd.mBytesPerPacket = channels * sizeof(float);
        asbd.mFramesPerPacket = 1;
        asbd.mBytesPerFrame = channels * sizeof(float);
        asbd.mChannelsPerFrame = channels;
        asbd.mBitsPerChannel = sizeof(float) * 8;

        status = AudioUnitSetProperty(m_audioUnit, kAudioUnitProperty_StreamFormat,
                                       kAudioUnitScope_Input, 0, &asbd, sizeof(asbd));
        if (status != noErr) {
            NSLog(@"[BionicSX2] AudioUnitSetProperty StreamFormat failed: %d", (int)status);
            return false;
        }

        AURenderCallbackStruct callback;
        callback.inputProc = RenderCallback;
        callback.inputProcRefCon = this;
        status = AudioUnitSetProperty(m_audioUnit, kAudioUnitProperty_SetRenderCallback,
                                       kAudioUnitScope_Input, 0, &callback, sizeof(callback));
        if (status != noErr) {
            NSLog(@"[BionicSX2] AudioUnitSetProperty RenderCallback failed: %d", (int)status);
            return false;
        }

        status = AudioUnitInitialize(m_audioUnit);
        if (status != noErr) {
            NSLog(@"[BionicSX2] AudioUnitInitialize failed: %d", (int)status);
            return false;
        }

        m_initialized = true;
        return true;
    }

    bool Start() {
        if (!m_initialized) return false;
        OSStatus status = AudioOutputUnitStart(m_audioUnit);
        if (status != noErr) {
            NSLog(@"[BionicSX2] AudioOutputUnitStart failed: %d", (int)status);
            return false;
        }
        return true;
    }

    void Stop() {
        if (m_audioUnit)
            AudioOutputUnitStop(m_audioUnit);
    }

    void Close() {
        Stop();
        if (m_audioUnit) {
            AudioUnitUninitialize(m_audioUnit);
            AudioComponentInstanceDispose(m_audioUnit);
            m_audioUnit = nullptr;
        }
        m_initialized = false;
    }

    void Write(const float* data, int frames) {
        if (!m_initialized) return;
        std::lock_guard<std::mutex> lock(m_mutex);
        int channels = 2;
        m_ringBuffer.insert(m_ringBuffer.end(), data, data + frames * channels);
    }

private:
    static OSStatus RenderCallback(void* inRefCon,
                                    AudioUnitRenderActionFlags* ioActionFlags,
                                    const AudioTimeStamp* inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList* ioData) {
        auto* self = static_cast<iOSAudioStream*>(inRefCon);
        std::lock_guard<std::mutex> lock(self->m_mutex);

        int channels = 2;
        int needed = inNumberFrames * channels;

        for (UInt32 i = 0; i < ioData->mNumberBuffers; i++) {
            float* buf = static_cast<float*>(ioData->mBuffers[i].mData);
            int available = static_cast<int>(self->m_ringBuffer.size());
            int toCopy = std::min(needed, available);
            if (toCopy > 0) {
                memcpy(buf, self->m_ringBuffer.data(), toCopy * sizeof(float));
                self->m_ringBuffer.erase(self->m_ringBuffer.begin(), self->m_ringBuffer.begin() + toCopy);
            }
            int remaining = needed - toCopy;
            if (remaining > 0)
                memset(buf + toCopy, 0, remaining * sizeof(float));
        }
        return noErr;
    }

    AudioUnit m_audioUnit = nullptr;
    bool m_initialized = false;
    std::mutex m_mutex;
    std::vector<float> m_ringBuffer;
};

static iOSAudioStream s_audioStream;

void iOSAudioInit() {
    iOSConfigureAudioSession();
    if (!s_audioStream.Init(48000, 2)) {
        NSLog(@"[BionicSX2] iOSAudioStream init failed");
    }
}

void iOSAudioStart() {
    s_audioStream.Start();
}

void iOSAudioStop() {
    s_audioStream.Stop();
}

void iOSAudioWrite(const float* data, int frames) {
    s_audioStream.Write(data, frames);
}

void iOSAudioClose() {
    s_audioStream.Close();
}
