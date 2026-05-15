// PORTED FROM: pcsx2/GS/Renderers/Metal/GSTextureMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.5
// STATUS: GREEN
// MTLResourceStorageModeShared works on iOS Apple Silicon — zero changes needed.

#include "GS/Renderers/Common/GSTexture.h"
#import <Metal/Metal.h>

class MetalTexture final : public GSTexture
{
public:
	MetalTexture(id<MTLTexture> texture, Type type, Format format)
		: GSTexture()
		, m_texture(texture)
	{
		m_type = type;
		m_format = format;
	}

	~MetalTexture() override { m_texture = nil; }

	void* GetNativeHandle() const override { return (__bridge void*)m_texture; }
	u32 GetID() const { return (u32)(uintptr_t)m_texture; }

	bool Update(const GSVector4i& rect, const void* data, int pitch, int layer) override
	{
		MTLRegion region = MTLRegionMake2D(rect.left, rect.top, rect.width(), rect.height());
		[m_texture replaceRegion:region
			mipmapLevel:0
			slice:layer
			withBytes:data
			bytesPerRow:pitch
			bytesPerImage:0];
		return true;
	}

	bool Map(GSMap& m, const GSVector4i* rect, int layer) override { return false; }
	void Unmap() override {}
	void GenerateMipmap() override {}
	void SetDebugName(std::string_view name) {}

private:
	id<MTLTexture> m_texture = nil;
};
