// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3, Phase 11
// STATUS: YELLOW
// Phase 11 bringup — CreateSurface/DoMerge/PresentRect wired.
// BIOS display now functional.

#include "MetalRenderer.h"
#include "GS/GSPerfMon.h"
#include "common/BitUtils.h"
#include "LogOverlay.h"
#include "BionicSX2Shared.h"
#include <vector>

// =====================================================================
// MetalTexture — minimal GSTexture subclass wrapping id<MTLTexture>
// =====================================================================

MetalTexture::MetalTexture(id<MTLTexture> texture, Type type, Format format)
	: m_texture(texture)
{
	m_type = type;
	m_format = format;
	m_size.x = static_cast<int>([texture width]);
	m_size.y = static_cast<int>([texture height]);
	m_mipmap_levels = static_cast<int>([texture mipmapLevelCount]);
}

MetalTexture::~MetalTexture()
{
	m_texture = nil;
}

void* MetalTexture::GetNativeHandle() const
{
	return (__bridge void*)m_texture;
}

bool MetalTexture::Update(const GSVector4i& r, const void* data, int pitch, int layer)
{
	[m_texture replaceRegion:MTLRegionMake2D(r.x, r.y, r.width(), r.height())
	             mipmapLevel:layer
	               withBytes:data
	             bytesPerRow:pitch];
	g_perfmon.Put(GSPerfMon::TextureUploads, 1);
	return true;
}

bool MetalTexture::Map(GSMap& m, const GSVector4i* _r, int layer)
{
	GSVector4i r = _r ? *_r : GSVector4i(0, 0, m_size.x, m_size.y);
	u32 bpp = (m_format == Format::UNorm8) ? 1 : 4;
	m.pitch = Common::AlignUpPow2(static_cast<u32>(r.width()) * bpp, 32);
	size_t size = static_cast<size_t>(r.height()) * m.pitch;
	m.bits = new u8[size];
	m_map_data.reset(m.bits);
	m_map_pitch = m.pitch;
	return true;
}

void MetalTexture::Unmap()
{
	if (!m_map_data)
		return;
	GSVector4i r(0, 0, m_size.x, m_size.y);
	u32 bpp = (m_format == Format::UNorm8) ? 1 : 4;
	u32 pitch = Common::AlignUpPow2(static_cast<u32>(m_size.x) * bpp, 32);
	[m_texture replaceRegion:MTLRegionMake2D(0, 0, m_size.x, m_size.y)
	             mipmapLevel:0
	               withBytes:m_map_data.get()
	             bytesPerRow:pitch];
	m_map_data.reset();
	m_map_pitch = 0;
}

void MetalTexture::GenerateMipmap()
{
}

#ifdef PCSX2_DEVBUILD
void MetalTexture::SetDebugName(std::string_view name)
{
}
#endif

// =====================================================================
// MetalRenderer implementation
// =====================================================================

MetalRenderer::MetalRenderer()
{
}

MetalRenderer::~MetalRenderer()
{
	Destroy();
}

bool MetalRenderer::Create(GSVSyncMode vsync_mode, bool allow_present_throttle)
{
    @autoreleasepool {
        @try {
            BXLog(@"MetalRenderer: step A — base GSDevice::Create");
            if (!GSDevice::Create(vsync_mode, allow_present_throttle))
            {
                BXLogError(@"MetalRenderer: GSDevice::Create (base) failed");
                return false;
            }
            BXLog(@"MetalRenderer: step A done (vsync=%d, throttle=%d)",
                  (int)vsync_mode, (int)allow_present_throttle);

            // ── Create MTLDevice ────────────────────────────────────────────
            BXLog(@"MetalRenderer: step B — MTLDevice");
            m_device = MTLCreateSystemDefaultDevice();
            if (!m_device)
            {
                BXLogError(@"MetalRenderer: MTLCreateSystemDefaultDevice returned nil");
                return false;
            }
            BXLog(@"MetalRenderer: step B done — device: %s", [[m_device name] UTF8String]);

            // ── Command queue ───────────────────────────────────────────────
            BXLog(@"MetalRenderer: step C — command queue");
            m_commandQueue = [m_device newCommandQueue];
            if (!m_commandQueue)
            {
                BXLogError(@"MetalRenderer: newCommandQueue returned nil");
                return false;
            }
            BXLog(@"MetalRenderer: step C done");

            // ── Get stored WindowInfo (set by BionicSX2Bridge.setMetalLayer:) ─
            BXLog(@"MetalRenderer: step D — WindowInfo");
            const WindowInfo* wi = BXSX2GetWindowInfo();
            if (!wi || !wi->surface_handle)
            {
                BXLogError(@"MetalRenderer: no WindowInfo — did you call setMetalLayer before startVM?");
                return false;
            }
            BXLog(@"MetalRenderer: step D done (surface_handle=%p)", wi->surface_handle);

            // ── CAMetalLayer from the view's backing layer ──────────────────
            BXLog(@"MetalRenderer: step E — CAMetalLayer");
            m_layer = (__bridge CAMetalLayer*)wi->surface_handle;
            if (!m_layer)
            {
                BXLogError(@"MetalRenderer: surface_handle is not a valid CAMetalLayer");
                return false;
            }

            [m_layer setDevice:m_device];
            [m_layer setPixelFormat:MTLPixelFormatBGRA8Unorm];
            [m_layer setFramebufferOnly:YES];
            [m_layer setContentsScale:wi->surface_scale ? wi->surface_scale : [UIScreen mainScreen].scale];

            // CRITICAL: set drawableSize from actual screen dimensions
            CGFloat drawW = wi->surface_width  > 0 ? wi->surface_width  : [UIScreen mainScreen].nativeBounds.size.width;
            CGFloat drawH = wi->surface_height > 0 ? wi->surface_height : [UIScreen mainScreen].nativeBounds.size.height;
            [m_layer setDrawableSize:CGSizeMake(drawW, drawH)];
            BXLog(@"MetalRenderer: step E done (drawableSize=%.0fx%.0f scale=%.1f)",
                  drawW, drawH, wi->surface_scale);

            // ── Load default.metallib from app bundle ────────────────────────
            BXLog(@"MetalRenderer: step F — load metallib");
            NSString* libPath = [[NSBundle mainBundle]
                pathForResource:@"default" ofType:@"metallib"];
            if (!libPath)
            {
                BXLogError(@"MetalRenderer: default.metallib not found in bundle");
                return false;
            }
            NSError* libErr = nil;
            m_library = [m_device newLibraryWithURL:[NSURL fileURLWithPath:libPath]
                                              error:&libErr];
            if (!m_library)
            {
                BXLogError(@"MetalRenderer: MTLLibrary load failed: %@", libErr);
                return false;
            }
            BXLog(@"MetalRenderer: step F done");

            // ── Build present pipeline (present_vertex + present_fragment) ───
            BXLog(@"MetalRenderer: step G — present pipeline");
            id<MTLFunction> vertFn = [m_library newFunctionWithName:@"present_vertex"];
            id<MTLFunction> fragFn = [m_library newFunctionWithName:@"present_fragment"];
            if (!vertFn || !fragFn)
            {
                BXLogError(@"MetalRenderer: present shader functions not found in metallib");
                return false;
            }
            MTLRenderPipelineDescriptor* desc = [[MTLRenderPipelineDescriptor alloc] init];
            desc.vertexFunction   = vertFn;
            desc.fragmentFunction = fragFn;
            desc.colorAttachments[0].pixelFormat = m_layer.pixelFormat;
            NSError* psoErr = nil;
            m_presentPSO = [m_device newRenderPipelineStateWithDescriptor:desc
                                                                    error:&psoErr];
            if (!m_presentPSO)
            {
                BXLogError(@"MetalRenderer: present PSO failed: %@", psoErr);
                return false;
            }
            BXLog(@"MetalRenderer: step G done — present pipeline ready");

            return true;
        } @catch (NSException *e) {
            BXLogError(@"MetalRenderer EXCEPTION: %@ — reason: %@", e.name, e.reason);
            return false;
        }
    }
}

bool MetalRenderer::SetWindow(const WindowInfo& wi)
{
    BXLog(@"MetalRenderer::SetWindow(surface_handle=%p)", wi.surface_handle);
	m_layer = (__bridge CAMetalLayer*)wi.surface_handle;
	if (m_layer)
	{
		[m_layer setContentsScale:wi.surface_scale ? wi.surface_scale : [UIScreen mainScreen].scale];
		[m_layer setDrawableSize:CGSizeMake(
			static_cast<CGFloat>(wi.surface_width),
			static_cast<CGFloat>(wi.surface_height))];
        BXLog(@"MetalRenderer::SetWindow: layer configured (%.0fx%.0f scale=%.1f)",
              wi.surface_width, wi.surface_height, wi.surface_scale);
	}
    else
    {
        BXLogError(@"MetalRenderer::SetWindow: surface_handle is null");
    }
	return true;
}

void MetalRenderer::Destroy()
{
	m_presentTexture = nil;
	m_presentPSO = nil;
	m_library = nil;
	m_uploadBuffer = nil;
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

		id<MTLCommandBuffer> cmd = [m_commandQueue commandBuffer];

		MTLRenderPassDescriptor* rpd = [MTLRenderPassDescriptor renderPassDescriptor];
		rpd.colorAttachments[0].texture     = drawable.texture;
		rpd.colorAttachments[0].loadAction  = MTLLoadActionClear;
		rpd.colorAttachments[0].storeAction = MTLStoreActionStore;
		rpd.colorAttachments[0].clearColor  = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);

		id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:rpd];
		if (m_presentPSO && m_presentTexture)
		{
			[enc setRenderPipelineState:m_presentPSO];
			[enc setFragmentTexture:m_presentTexture atIndex:0];
			[enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
		}
		[enc endEncoding];

		[cmd presentDrawable:drawable];
		[cmd commit];
	}
}

void MetalRenderer::RenderSW(GSTexture* src, const GSVector4i& bounds)
{
	if (!src)
	{
		RenderHW(nullptr);
		return;
	}
	// SW renderer output → set as present texture for next VSync
	m_presentTexture = GetMTLTexture(src);
}

void MetalRenderer::Present()
{
}

// =====================================================================
// GSDevice pure virtual implementations — Phase 11 bringup (Audit Sec 4.1)
// =====================================================================

using Format = GSTexture::Format;
using Type = GSTexture::Type;

MTLPixelFormat MetalRenderer::FormatToMTL(GSTexture::Format fmt)
{
	switch (fmt)
	{
		case Format::Color:    return MTLPixelFormatRGBA8Unorm;
		case Format::ColorHQ:  return MTLPixelFormatRGB10A2Unorm;
		case Format::ColorHDR: return MTLPixelFormatRGBA16Float;
		case Format::DepthStencil: return MTLPixelFormatDepth32Float_Stencil8;
		case Format::UNorm8:   return MTLPixelFormatR8Unorm;
		case Format::UInt16:   return MTLPixelFormatR16Uint;
		case Format::UInt32:   return MTLPixelFormatR32Uint;
		case Format::PrimID:   return MTLPixelFormatR32Uint;
		default:               return MTLPixelFormatRGBA8Unorm;
	}
}

id<MTLTexture> MetalRenderer::GetMTLTexture(GSTexture* tex)
{
	if (!tex) return nil;
	return (__bridge id<MTLTexture>)tex->GetNativeHandle();
}

void MetalRenderer::BlitTexture(GSTexture* sTex, const GSVector4& sRect,
	GSTexture* dTex, const GSVector4& dRect)
{
	id<MTLTexture> src = GetMTLTexture(sTex);
	id<MTLTexture> dst = GetMTLTexture(dTex);
	if (!src || !dst) return;

	id<MTLCommandBuffer> cmd = [m_commandQueue commandBuffer];
	id<MTLBlitCommandEncoder> enc = [cmd blitCommandEncoder];

	[enc copyFromTexture:src
	        sourceSlice:0
	        sourceLevel:0
	       sourceOrigin:MTLOriginMake(
	       	static_cast<NSUInteger>(sRect.x),
	       	static_cast<NSUInteger>(sRect.y), 0)
	         sourceSize:MTLSizeMake(
	       	static_cast<NSUInteger>(sRect.z - sRect.x),
	       	static_cast<NSUInteger>(sRect.w - sRect.y), 1)
	          toTexture:dst
	   destinationSlice:0
	   destinationLevel:0
	  destinationOrigin:MTLOriginMake(
	  	static_cast<NSUInteger>(dRect.x),
	  	static_cast<NSUInteger>(dRect.y), 0)];

	[enc endEncoding];
	[cmd commit];
}

GSTexture* MetalRenderer::CreateSurface(Type type, int width, int height, int levels, Format format)
{
	MTLPixelFormat mtlFmt = FormatToMTL(format);
	if (mtlFmt == MTLPixelFormatInvalid)
	{
		NSLog(@"[BionicSX2] CreateSurface: unsupported format %d", static_cast<int>(format));
		return nullptr;
	}

	MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:mtlFmt
		width:static_cast<NSUInteger>(width)
		height:static_cast<NSUInteger>(height)
		mipmapped:(levels > 1)];

	switch (type)
	{
		case Type::RenderTarget:
			desc.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
			break;
		case Type::DepthStencil:
			desc.usage = MTLTextureUsageRenderTarget;
			break;
		case Type::Texture:
		case Type::RWTexture:
			desc.usage = MTLTextureUsageShaderRead;
			if (type == Type::RWTexture)
				desc.usage |= MTLTextureUsageShaderWrite;
			break;
		default:
			desc.usage = MTLTextureUsageShaderRead;
			break;
	}

	if (levels > 1)
		desc.mipmapLevelCount = static_cast<NSUInteger>(levels);

	id<MTLTexture> tex = [m_device newTextureWithDescriptor:desc];
	if (!tex)
	{
		NSLog(@"[BionicSX2] CreateSurface: failed to create %dx%d MTLTexture",
			width, height);
		return nullptr;
	}

	return new MetalTexture(tex, type, format);
}

void MetalRenderer::DoMerge(GSTexture* sTex[3], GSVector4* sRect, GSTexture* dTex,
	GSVector4* dRect, const GSRegPMODE& PMODE, const GSRegEXTBUF& EXTBUF,
	u32 c, const bool linear)
{
	if (!sTex[0] || !dTex)
		return;

	// Simple blit: copy first source to destination
	BlitTexture(sTex[0], sRect[0], dTex, *dRect);
}

void MetalRenderer::DoInterlace(GSTexture*, const GSVector4&, GSTexture*,
	const GSVector4&, ShaderInterlace, bool, const InterlaceConstantBuffer&)
{
}

void MetalRenderer::DoFXAA(GSTexture*, GSTexture*) {}
void MetalRenderer::DoShadeBoost(GSTexture*, GSTexture*, const float[4]) {}
bool MetalRenderer::DoCAS(GSTexture*, GSTexture*, bool, const std::array<u32, NUM_CAS_CONSTANTS>&) { return false; }

void MetalRenderer::DoStretchRect(GSTexture* sTex, const GSVector4& sRect,
	GSTexture* dTex, const GSVector4& dRect,
	GSHWDrawConfig::ColorMaskSelector, ShaderConvert, bool)
{
	if (!sTex || !dTex)
		return;
	BlitTexture(sTex, sRect, dTex, dRect);
}

RenderAPI MetalRenderer::GetRenderAPI() const { return RenderAPI::Metal; }
bool MetalRenderer::HasSurface() const { return m_layer != nil; }

void MetalRenderer::DestroySurface()
{
}

bool MetalRenderer::UpdateWindow() { return true; }
void MetalRenderer::ResizeWindow(u32 new_window_width, u32 new_window_height, float new_window_scale)
{
	ResizeWindow(static_cast<s32>(new_window_width), static_cast<s32>(new_window_height));
}

bool MetalRenderer::SupportsExclusiveFullscreen() const { return false; }

MetalRenderer::PresentResult MetalRenderer::BeginPresent(bool)
{
	return PresentResult::OK;
}

void MetalRenderer::EndPresent()
{
}

void MetalRenderer::SetVSyncMode(GSVSyncMode, bool) {}

std::string MetalRenderer::GetDriverInfo() const
{
	return "Metal (BionicSX2 – Phase 11 bringup)";
}

bool MetalRenderer::SetGPUTimingEnabled(bool) { return false; }
float MetalRenderer::GetAndResetAccumulatedGPUTime() { return 0.0f; }
void MetalRenderer::PushDebugGroup(const char*, ...) {}
void MetalRenderer::PopDebugGroup() {}
void MetalRenderer::InsertDebugMessage(DebugMessageCategory, const char*, ...) {}

std::unique_ptr<GSDownloadTexture> MetalRenderer::CreateDownloadTexture(u32, u32, GSTexture::Format)
{
	return nullptr;
}

void MetalRenderer::CopyRect(GSTexture* sTex, GSTexture* dTex, const GSVector4i& r, u32 destX, u32 destY)
{
	if (!sTex || !dTex)
		return;
	GSVector4 sRect(static_cast<float>(r.x), static_cast<float>(r.y),
	                static_cast<float>(r.z), static_cast<float>(r.w));
	GSVector4 dRect(static_cast<float>(destX), static_cast<float>(destY),
	                static_cast<float>(destX + r.width()),
	                static_cast<float>(destY + r.height()));
	BlitTexture(sTex, sRect, dTex, dRect);
}

void MetalRenderer::PresentRect(GSTexture* sTex, const GSVector4& sRect,
	GSTexture* dTex, const GSVector4& dRect,
	PresentShader shader, float shaderTime, bool linear)
{
	if (dTex)
	{
		// Render to texture → use blit
		BlitTexture(sTex, sRect, dTex, dRect);
	}
	else if (sTex)
	{
		// Present to screen drawable
		id<MTLTexture> srcTex = GetMTLTexture(sTex);
		if (!srcTex) return;

		@autoreleasepool {
			id<CAMetalDrawable> drawable = [m_layer nextDrawable];
			if (!drawable) return;

			id<MTLCommandBuffer> cmd = [m_commandQueue commandBuffer];
			MTLRenderPassDescriptor* rpd = [MTLRenderPassDescriptor renderPassDescriptor];
			rpd.colorAttachments[0].texture     = drawable.texture;
			rpd.colorAttachments[0].loadAction  = MTLLoadActionClear;
			rpd.colorAttachments[0].storeAction = MTLStoreActionStore;
			rpd.colorAttachments[0].clearColor  = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);

			id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:rpd];
			if (m_presentPSO)
			{
				[enc setRenderPipelineState:m_presentPSO];
				[enc setFragmentTexture:srcTex atIndex:0];
				[enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
			}
			[enc endEncoding];
			[cmd presentDrawable:drawable];
			[cmd commit];
		}
	}
}

void MetalRenderer::UpdateCLUTTexture(GSTexture*, float, u32, u32, GSTexture*, u32, u32) {}
void MetalRenderer::ConvertToIndexedTexture(GSTexture*, float, u32, u32, u32, u32, GSTexture*, u32, u32) {}
void MetalRenderer::FilteredDownsampleTexture(GSTexture*, GSTexture*, u32, const GSVector2i&, const GSVector4&) {}
void MetalRenderer::RenderHW(GSHWDrawConfig&) {}
void MetalRenderer::ClearSamplerCache() {}

// Factory function — called from GSDevice.cpp CreateGSDevice()
GSDevice* MakeGSDeviceMTL()
{
    return new MetalRenderer();
}
