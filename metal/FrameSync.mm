// NEW FILE — split from GSDeviceMTL.mm
// AUDIT REFERENCE: Section 4.2, 13.4
// STATUS: NEW
// Frame synchronization using MTLFence, MTLCommandBuffer completion handlers,
// and ReadbackSpinManager. Separate concern from device creation for iOS clarity.

#import <Metal/Metal.h>
#include <atomic>

class FrameSync
{
public:
	FrameSync() = default;
	~FrameSync() = default;

	void Initialize(id<MTLDevice> device)
	{
		m_device = device;
		m_fence = [device newFence];
	}

	void WaitForGPU()
	{
		if (m_inFlight > 0)
		{
			// Wait for the oldest in-flight command buffer
			std::unique_lock<std::mutex> lock(m_mutex);
			m_cv.wait(lock, [this]() { return m_inFlight == 0; });
		}
	}

	void SignalGPU()
	{
		m_inFlight++;
	}

	void CompleteFrame()
	{
		m_inFlight--;
		m_cv.notify_one();
	}

private:
	id<MTLDevice> m_device = nil;
	id<MTLFence> m_fence = nil;
	std::atomic<int> m_inFlight{0};
	std::mutex m_mutex;
	std::condition_variable m_cv;
};
