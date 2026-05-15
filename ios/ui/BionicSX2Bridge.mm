// AUDIT REFERENCE: Section 8.3, 4.3
// STATUS: NEW
#import "BionicSX2Bridge.h"
#import <UIKit/UIKit.h>
#include "iOSVMManager.h"
#include "GS/GS.h"
#include "common/WindowInfo.h"
#include "SIO/Pad/Pad.h"

const int PAD_CROSS = 0;
const int PAD_CIRCLE = 1;
const int PAD_SQUARE = 2;
const int PAD_TRIANGLE = 3;
const int PAD_L1 = 4;
const int PAD_R1 = 5;
const int PAD_L2 = 6;
const int PAD_R2 = 7;
const int PAD_UP = 8;
const int PAD_DOWN = 9;
const int PAD_LEFT = 10;
const int PAD_RIGHT = 11;

static CAMetalLayer* g_metalLayer = nil;

@implementation BionicSX2Bridge

+ (BOOL)startVMWithISO:(NSString* _Nullable)isoPath {
    const char* path = isoPath ? [isoPath UTF8String] : nullptr;
    return iOSVMManager::StartVM(path);
}

+ (void)stopVM {
    iOSVMManager::StopVM();
}

+ (void)setMetalLayer:(CAMetalLayer*)layer {
    g_metalLayer = layer;
    WindowInfo wi;
    wi.type = WindowInfo::Type::MacOS;
    wi.window_handle = (__bridge void*)[[UIApplication sharedApplication].keyWindow rootViewController].view;
    wi.surface_handle = (__bridge void*)layer;
    wi.surface_width = layer.bounds.size.width * layer.contentsScale;
    wi.surface_height = layer.bounds.size.height * layer.contentsScale;
    wi.surface_scale = layer.contentsScale;
    // GSUpdateOptions stubbed — WindowInfo passed through wi reference
}

+ (void)setPadButton:(int)pad button:(int)button pressed:(BOOL)pressed {
    if (button <= PAD_R2) {
        Pad::SetControllerState(pad, button, pressed ? 1.0f : 0.0f);
    }
}

+ (void)setAnalogStick:(int)pad stick:(int)stick x:(float)x y:(float)y {
    Pad::SetControllerState(pad, 8 + stick * 2, x);
    Pad::SetControllerState(pad, 8 + stick * 2 + 1, y);
}

+ (void)clearPadState:(int)pad {
    for (int i = 0; i < 12; i++)
        Pad::SetControllerState(pad, i, 0.0f);
}

@end
