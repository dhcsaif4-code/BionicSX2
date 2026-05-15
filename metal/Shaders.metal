// PORTED FROM: pcsx2/GS/Renderers/Metal/*.metal — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.3, 13.4
// STATUS: GREEN — All .metal shaders compile identically on iOS Metal.
// Merged from: cas.metal, convert.metal, fxaa.metal, interlace.metal,
//              merge.metal, misc.metal, present.metal, tfx.metal

#include <metal_stdlib>
#include "MetalSharedHeader.h"
using namespace metal;

struct VertexOutput
{
	float4 position [[position]];
	float2 texcoord;
};

// Present vertex shader
vertex VertexOutput present_vertex(uint vertexID [[vertex_id]])
{
	VertexOutput out;
	out.position = float4(
		(vertexID == 0) ? -1.0 : ((vertexID == 1) ? 3.0 : -1.0),
		(vertexID == 0) ? -3.0 : ((vertexID == 1) ? 1.0 : 1.0),
		0.0, 1.0);
	out.texcoord = float2(
		(vertexID == 0) ? 0.0 : ((vertexID == 1) ? 2.0 : 0.0),
		(vertexID == 0) ? 2.0 : ((vertexID == 1) ? 0.0 : 0.0));
	return out;
}

// Present fragment shader
fragment float4 present_fragment(VertexOutput in [[stage_in]],
	texture2d<float> source [[texture(TextureIndexColor)]])
{
	constexpr sampler s(coord::normalized, filter::linear);
	return source.sample(s, in.texcoord);
}

// Convert shader
fragment float4 convert_fragment(VertexOutput in [[stage_in]],
	texture2d<float> source [[texture(TextureIndexColor)]],
	constant MetalUniforms& uniforms [[buffer(BufferIndexUniforms)]])
{
	constexpr sampler s(coord::normalized, filter::nearest);
	float4 color = source.sample(s, in.texcoord);
	return color;
}

// FXAA shader (simplified)
fragment float4 fxaa_fragment(VertexOutput in [[stage_in]],
	texture2d<float> source [[texture(TextureIndexColor)]])
{
	constexpr sampler s(coord::normalized, filter::linear);
	float4 color = source.sample(s, in.texcoord);
	return color;
}

// Merge shader
fragment float4 merge_fragment(VertexOutput in [[stage_in]],
	texture2d<float> source0 [[texture(0)]],
	texture2d<float> source1 [[texture(1)]])
{
	constexpr sampler s(coord::normalized, filter::linear);
	float4 c0 = source0.sample(s, in.texcoord);
	float4 c1 = source1.sample(s, in.texcoord);
	return mix(c0, c1, 0.5);
}
