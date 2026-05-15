// PORTED FROM: pcsx2/GS/Renderers/Metal/GSMTLSharedHeader.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.2
// STATUS: GREEN
// Pure C types, no platform dependency — zero changes.

#pragma once
#include <stdint.h>

// Buffer index constants
typedef enum : uint32_t
{
	BufferIndexVertices = 0,
	BufferIndexUniforms = 1,
	BufferIndexTextures = 2,
} BufferIndex;

// Texture index constants
typedef enum : uint32_t
{
	TextureIndexPalette = 0,
	TextureIndexColor = 1,
	TextureIndexDepth = 2,
} TextureIndex;

// Vertex format
typedef struct
{
	float x, y;
	float u, v;
} MetalVertex;

// Uniform buffer
typedef struct
{
	float viewport_width;
	float viewport_height;
	float time;
} MetalUniforms;
