#pragma once

#include "common/WindowInfo.h"

/// Stores the WindowInfo set by BionicSX2Bridge.setMetalLayer:
/// Used by MetalRenderer::Create to find its CAMetalLayer.
void BXSX2SetWindowInfo(const WindowInfo& wi);
const WindowInfo* BXSX2GetWindowInfo();

/// Stores a UIView reference for window_handle.
void BXSX2SetViewHandle(void* view);
void* BXSX2GetViewHandle();
