// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3
// STATUS: YELLOW
// PORTED: NSView → UIView (Audit Sec 4.3)
#pragma once

#include "GS/Renderers/Common/GSDevice.h"
#include "GS/GS.h"
#include "GS/Renderers/HW/GSTextureCache.h"
#include "common/WindowInfo.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

class MetalRenderer final : public GSDevice
{
public:
	MetalRenderer();
	~MetalRenderer() override;

	bool Create(const WindowInfo& wi, std::string_view error);
	bool SetWindow(const WindowInfo& wi);
	void Destroy();
	void* GetDevice() const { return (__bridge void*)m_device; }

	void ResizeWindow(s32 new_width, s32 new_height);

	bool DoPreload(const GSDevice::FeatureSupport& features, std::string_view error);
	void RenderHW(GSTextureCache* tc);
	void RenderSW(GSTexture* src, const GSVector4i& bounds);

	void Present();

	// GSDevice pure virtual stubs — Phase 11 (Audit Sec 4.1-4.3)
	GSTexture* CreateSurface(GSTexture::Type type, int width, int height, int levels, GSTexture::Format format) override;
	void DoMerge(GSTexture* sTex[3], GSVector4* sRect, GSTexture* dTex, GSVector4* dRect, const GSRegPMODE& PMODE, const GSRegEXTBUF& EXTBUF, u32 c, const bool linear) override;
	void DoInterlace(GSTexture* sTex, const GSVector4& sRect, GSTexture* dTex, const GSVector4& dRect, ShaderInterlace shader, bool linear, const InterlaceConstantBuffer& cb) override;
	void DoFXAA(GSTexture* sTex, GSTexture* dTex) override;
	void DoShadeBoost(GSTexture* sTex, GSTexture* dTex, const float params[4]) override;
	bool DoCAS(GSTexture* sTex, GSTexture* dTex, bool sharpen_only, const std::array<u32, NUM_CAS_CONSTANTS>& constants) override;
	void DoStretchRect(GSTexture* sTex, const GSVector4& sRect, GSTexture* dTex, const GSVector4& dRect, GSHWDrawConfig::ColorMaskSelector cms, ShaderConvert shader, bool linear) override;
	GSDevice::RenderAPI GetRenderAPI() const override;
	bool HasSurface() const override;
	void DestroySurface() override;
	bool UpdateWindow() override;
	void ResizeWindow(u32 new_window_width, u32 new_window_height, float new_window_scale) override;
	bool SupportsExclusiveFullscreen() const override;
	PresentResult BeginPresent(bool frame_skip) override;
	void EndPresent() override;
	void SetVSyncMode(GSVSyncMode mode, bool allow_present_throttle) override;
	std::string GetDriverInfo() const override;
	bool SetGPUTimingEnabled(bool enabled) override;
	float GetAndResetAccumulatedGPUTime() override;
	void PushDebugGroup(const char* fmt, ...) override;
	void PopDebugGroup() override;
	void InsertDebugMessage(DebugMessageCategory category, const char* fmt, ...) override;
	std::unique_ptr<GSDownloadTexture> CreateDownloadTexture(u32 width, u32 height, GSTexture::Format format) override;
	void CopyRect(GSTexture* sTex, GSTexture* dTex, const GSVector4i& r, u32 destX, u32 destY) override;
	void PresentRect(GSTexture* sTex, const GSVector4& sRect, GSTexture* dTex, const GSVector4& dRect, PresentShader shader, float shaderTime, bool linear) override;
	void UpdateCLUTTexture(GSTexture* sTex, float sScale, u32 offsetX, u32 offsetY, GSTexture* dTex, u32 dOffset, u32 dSize) override;
	void ConvertToIndexedTexture(GSTexture* sTex, float sScale, u32 offsetX, u32 offsetY, u32 SBW, u32 SPSM, GSTexture* dTex, u32 DBW, u32 DPSM) override;
	void FilteredDownsampleTexture(GSTexture* sTex, GSTexture* dTex, u32 downsample_factor, const GSVector2i& clamp_min, const GSVector4& dRect) override;
	void RenderHW(GSHWDrawConfig& config) override;
	void ClearSamplerCache() override;

private:
	id<MTLDevice> m_device = nil;
	id<MTLCommandQueue> m_commandQueue = nil;
	CAMetalLayer* m_layer = nil;
};
