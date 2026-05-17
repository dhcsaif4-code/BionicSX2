#pragma once

#include "common/WindowInfo.h"

/// Stores the WindowInfo set by BionicSX2Bridge.setMetalLayer:
/// Used by MetalRenderer::Create to find its CAMetalLayer.
void BXSX2SetWindowInfo(const WindowInfo& wi);
const WindowInfo* BXSX2GetWindowInfo();

/// Stores a UIView reference for window_handle.
void BXSX2SetViewHandle(void* view);
void* BXSX2GetViewHandle();

/// C-compatible logging for debug tracing.
/// Writes to runtime.log with timestamp via the ObjC Logger.
/// Safe to call from C/C++ code (no ObjC dependency).
void BLogC(const char* msg);
