#import "AppDelegate.h"
#import "MetalViewController.h"
#include "LogOverlay.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    BXSX2InstallCrashHandlers();
    [LogOverlay shared];
    BXLog(@"App launched — ObjC AppDelegate (no SceneDelegate)");

    iOSConfigureAudioSession();
    BXLog(@"Audio session configured");

    application.idleTimerDisabled = YES;
    BXLog(@"Idle timer disabled");

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    BXLog(@"Window size: %.0f x %.0f",
          self.window.bounds.size.width,
          self.window.bounds.size.height);

    MetalViewController *rootVC = [[MetalViewController alloc] init];
    self.window.rootViewController = rootVC;
    BXLog(@"rootViewController assigned");

    [self.window makeKeyAndVisible];
    BXLog(@"Window is visible");

    [[LogOverlay shared] installInWindow:self.window];
    BXLog(@"LogOverlay installed on window");

    return YES;
}

@end
