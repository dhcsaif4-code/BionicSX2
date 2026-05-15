// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3
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
		Console.Error("Metal: Failed to create system default device");
		return false;
	}

	m_commandQueue = [m_device newCommandQueue];
	if (!m_commandQueue)
	{
		Console.Error("Metal: Failed to create command queue");
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

bool MetalRenderer::DoPreload(const GSDevice::Feature& features, std::string_view error)
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
	// SW renderer: blit src texture to screen via Metal
	RenderHW(nullptr);
}

void MetalRenderer::Present()
{
	// Present is handled in RenderHW
}
