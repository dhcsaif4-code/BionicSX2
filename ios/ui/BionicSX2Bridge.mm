// AUDIT REFERENCE: Section 8.3, 4.3
// STATUS: NEW
#import "BionicSX2Bridge.h"
#import <UIKit/UIKit.h>
#include "iOSVMManager.h"
#include "GS/GS.h"
#include "common/WindowInfo.h"
#include "SIO/Pad/Pad.h"
#include "BionicSX2Shared.h"

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

static WindowInfo g_storedWindowInfo;

void BXSX2SetWindowInfo(const WindowInfo& wi) {
    g_storedWindowInfo = wi;
}
const WindowInfo* BXSX2GetWindowInfo() {
    return &g_storedWindowInfo;
}

static void* g_viewHandle = nil;
void BXSX2SetViewHandle(void* view) {
    g_viewHandle = view;
}
void* BXSX2GetViewHandle() {
    return g_viewHandle;
}

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
    UIWindow *window = nil;
    for (UIWindowScene *scene in
         [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState ==
            UISceneActivationStateForegroundActive) {
            window = scene.windows.firstObject;
            break;
        }
    }
    wi.window_handle = (__bridge void*)window.rootViewController.view;
    wi.surface_handle = (__bridge void*)layer;
    // Use screen bounds directly — layer bounds may not be final in viewDidLoad
    CGSize screenPt = UIScreen.mainScreen.bounds.size;
    CGFloat screenScale = UIScreen.mainScreen.scale;
    wi.surface_width  = screenPt.width * screenScale;
    wi.surface_height = screenPt.height * screenScale;
    wi.surface_scale  = screenScale;
    BXSX2SetWindowInfo(wi);
    if (wi.window_handle)
        BXSX2SetViewHandle(wi.window_handle);
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
