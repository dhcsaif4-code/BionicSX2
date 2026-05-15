// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3, Phase 11
// STATUS: YELLOW
// PORTED: NSView → UIView, NSWindow → UIWindow (Audit Sec 4.3)
// REMOVED: AMD slow_color_compression heuristic (Audit Sec 13.4)
// REMOVED: MTLCreateSystemDefaultDevice multi-GPU fallback — iOS has one GPU

#include "MetalRenderer.h"
#include "GS/GSPerfMon.h"

MetalRenderer::MetalRenderer()
{
}

MetalRenderer::~MetalRenderer()
{
	Destroy();
}

bool MetalRenderer::Create(const WindowInfo& wi, std::string_view error)
{
	m_device = MTLCreateSystemDefaultDevice();
	if (!m_device)
	{
		NSLog(@"[BionicSX2] Metal: Failed to create system default device");
		return false;
	}

	m_commandQueue = [m_device newCommandQueue];
	if (!m_commandQueue)
	{
		NSLog(@"[BionicSX2] Metal: Failed to create command queue");
		return false;
	}

	// PORTED: CAMetalLayer from UIView (Audit Section 4.3)
	m_layer = (__bridge CAMetalLayer*)wi.surface_handle;
	if (!m_layer)
	{
		m_layer = [CAMetalLayer layer];
		UIView* view = (__bridge UIView*)wi.window_handle;
		[view setLayer:m_layer];
	}

	[m_layer setDevice:m_device];
	[m_layer setPixelFormat:MTLPixelFormatBGRA8Unorm];
	[m_layer setFramebufferOnly:YES];
	[m_layer setContentsScale:wi.surface_scale ? wi.surface_scale : [UIScreen mainScreen].scale];

	return true;
}

bool MetalRenderer::SetWindow(const WindowInfo& wi)
{
	m_layer = (__bridge CAMetalLayer*)wi.surface_handle;
	if (m_layer)
	{
		[m_layer setContentsScale:wi.surface_scale ? wi.surface_scale : [UIScreen mainScreen].scale];
		[m_layer setDrawableSize:CGSizeMake(
			static_cast<CGFloat>(wi.surface_width),
			static_cast<CGFloat>(wi.surface_height))];
	}
	return true;
}

void MetalRenderer::Destroy()
{
	m_commandQueue = nil;
	m_device = nil;
	m_layer = nil;
}

void MetalRenderer::ResizeWindow(s32 new_width, s32 new_height)
{
	if (m_layer)
	{
		CGFloat scale = [m_layer contentsScale];
		[m_layer setDrawableSize:CGSizeMake(new_width * scale, new_height * scale)];
	}
}

bool MetalRenderer::DoPreload(const GSDevice::FeatureSupport& features, std::string_view error)
{
	return true;
}

void MetalRenderer::RenderHW(GSTextureCache* tc)
{
	@autoreleasepool {
		id<CAMetalDrawable> drawable = [m_layer nextDrawable];
		if (!drawable) return;

		id<MTLCommandBuffer> cmdBuffer = [m_commandQueue commandBuffer];

		MTLRenderPassDescriptor* passDesc = [MTLRenderPassDescriptor renderPassDescriptor];
		passDesc.colorAttachments[0].texture = drawable.texture;
		passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
		passDesc.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
		passDesc.colorAttachments[0].storeAction = MTLStoreActionStore;

		id<MTLRenderCommandEncoder> enc = [cmdBuffer renderCommandEncoderWithDescriptor:passDesc];
		[enc endEncoding];

		[cmdBuffer presentDrawable:drawable];
		[cmdBuffer commit];
	}
}

void MetalRenderer::RenderSW(GSTexture* src, const GSVector4i& bounds)
{
	RenderHW(nullptr);
}

void MetalRenderer::Present()
{
}

// =====================================================================
// GSDevice pure virtual method stubs — Phase 11 bringup (Audit Sec 4.1)
// All stubs return safe defaults. Real Metal rendering implementation
// to be added in subsequent phases.
// =====================================================================

GSTexture* MetalRenderer::CreateSurface(GSTexture::Type, int, int, int, GSTexture::Format) { return nullptr; }
void MetalRenderer::DoMerge(GSTexture**, GSVector4*, GSTexture*, GSVector4*, const GSRegPMODE&, const GSRegEXTBUF&, u32, const bool) {}
void MetalRenderer::DoInterlace(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, ShaderInterlace, bool, const InterlaceConstantBuffer&) {}
void MetalRenderer::DoFXAA(GSTexture*, GSTexture*) {}
void MetalRenderer::DoShadeBoost(GSTexture*, GSTexture*, const float[4]) {}
bool MetalRenderer::DoCAS(GSTexture*, GSTexture*, bool, const std::array<u32, NUM_CAS_CONSTANTS>&) { return false; }
void MetalRenderer::DoStretchRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, ShaderConvert, bool) {}
MetalRenderer::RenderAPI MetalRenderer::GetRenderAPI() const { return RenderAPI::Metal; }
bool MetalRenderer::HasSurface() const { return m_layer != nil; }
void MetalRenderer::DestroySurface() {}
bool MetalRenderer::UpdateWindow() { return true; }
void MetalRenderer::ResizeWindow(u32 new_window_width, u32 new_window_height, float new_window_scale) { ResizeWindow(static_cast<s32>(new_window_width), static_cast<s32>(new_window_height)); }
bool MetalRenderer::SupportsExclusiveFullscreen() const { return false; }
MetalRenderer::PresentResult MetalRenderer::BeginPresent(bool) { return PresentResult::OK; }
void MetalRenderer::EndPresent() {}
void MetalRenderer::SetVSyncMode(GSVSyncMode, bool) {}
std::string MetalRenderer::GetDriverInfo() const { return "Metal (BionicSX2 iOS bringup)"; }
bool MetalRenderer::SetGPUTimingEnabled(bool) { return false; }
float MetalRenderer::GetAndResetAccumulatedGPUTime() { return 0.0f; }
void MetalRenderer::PushDebugGroup(const char*, ...) {}
void MetalRenderer::PopDebugGroup() {}
void MetalRenderer::InsertDebugMessage(DebugMessageCategory, const char*, ...) {}
std::unique_ptr<GSDownloadTexture> MetalRenderer::CreateDownloadTexture(u32, u32, GSTexture::Format) { return nullptr; }
void MetalRenderer::CopyRect(GSTexture*, GSTexture*, const GSVector4i&, u32, u32) {}
void MetalRenderer::PresentRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, PresentShader, float, bool) {}
void MetalRenderer::UpdateCLUTTexture(GSTexture*, float, u32, u32, GSTexture*, u32, u32) {}
void MetalRenderer::ConvertToIndexedTexture(GSTexture*, float, u32, u32, u32, u32, GSTexture*, u32, u32) {}
void MetalRenderer::FilteredDownsampleTexture(GSTexture*, GSTexture*, u32, const GSVector2i&, const GSVector4&) {}
void MetalRenderer::RenderHW(GSHWDrawConfig&) {}
void MetalRenderer::ClearSamplerCache() {}
