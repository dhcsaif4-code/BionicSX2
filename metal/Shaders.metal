// metal/Shaders.metal — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2
// STATUS: YELLOW — present pass uses upstream GSMTLSharedHeader structs
// Full tfx/convert/fxaa/interlace/cas come from upstream compiled separately

#include <metal_stdlib>
using namespace metal;

// ── Use upstream shared header (matches GSDeviceMTL pipeline layout) ──
#include "GSMTLSharedHeader.h"

struct FullscreenVertex {
    float4 position [[position]];
    float2 uv;
};

// Full-screen triangle — no vertex buffer needed
vertex FullscreenVertex present_vertex(uint vid [[vertex_id]]) {
    FullscreenVertex out;
    float2 pos = float2((vid == 1) ? 3.0 : -1.0,
                        (vid == 2) ? 3.0 : -1.0);
    out.position = float4(pos, 0.0, 1.0);
    out.uv       = float2((vid == 1) ? 2.0 : 0.0,
                          (vid == 2) ? 0.0 : 2.0);
    return out;
}

// Simple blit — no CRT, no bloom — Phase 0 present pass
fragment float4 present_fragment(
    FullscreenVertex     in  [[stage_in]],
    texture2d<float>     tex [[texture(0)]],
    sampler              s   [[sampler(0)]])
{
    return tex.sample(s, in.uv);
}
