// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3
// STATUS: YELLOW
#pragma once

#include "GS/Renderers/Common/GSDevice.h"
#include "GS/GS.h"
#include "common/WindowInfo.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

class MetalRenderer final : public GSDevice
{
public:
	MetalRenderer();
	~MetalRenderer() override;

	bool Create(const WindowInfo& wi, std::string_view error) override;
	bool SetWindow(const WindowInfo& wi) override;
	void Destroy() override;
	void* GetDevice() const { return (__bridge void*)m_device; }

	void ResizeWindow(s32 new_width, s32 new_height) override;

	bool DoPreload(const GSDevice::Feature& features, std::string_view error) override;
	void RenderHW(GSTextureCache* tc) override;
	void RenderSW(GSTexture* src, const GSVector4i& bounds) override;

	void Present() override;

private:
	id<MTLDevice> m_device = nil;
	id<MTLCommandQueue> m_commandQueue = nil;
	CAMetalLayer* m_layer = nil;
};
