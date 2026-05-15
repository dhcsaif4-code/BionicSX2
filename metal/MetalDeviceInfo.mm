// PORTED FROM: pcsx2/GS/Renderers/Metal/GSMTLDeviceInfo.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.2, 13.4
// STATUS: GREEN
// REMOVED: AMD slow_color_compression heuristic (Audit Sec 13.4)
// Device feature detection works unchanged on iOS Apple GPU.

#import <Metal/Metal.h>
#include "GS/GS.h"

bool MetalDeviceSupportsFeature(const char* featureName)
{
	id<MTLDevice> device = MTLCreateSystemDefaultDevice();
	if (!device) return false;

	if (strcmp(featureName, "slow_color_compression") == 0)
		return false; // AUDIT: AMD-specific heuristic removed for iOS

	if (strcmp(featureName, "bgra_10_11_11_10") == 0)
		return [device supportsFamily:MTLGPUFamilyApple7];

	if (strcmp(featureName, "tile_based_deferred") == 0)
		return [device supportsFamily:MTLGPUFamilyApple1];

	return false;
}
