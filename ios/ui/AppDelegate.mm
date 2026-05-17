#import "AppDelegate.h"
#import "MetalViewController.h"
#include "LogOverlay.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    BXSX2InstallCrashHandlers();
    [LogOverlay shared];  // writes ===== APP STARTED =====
    BXLog(@"App launched — ObjC AppDelegate");

    iOSConfigureAudioSession();
    BXLog(@"Audio session configured");

    application.idleTimerDisabled = YES;
    BXLog(@"Idle timer disabled");

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    BXLog(@"Window: %.0fx%.0f",
          self.window.frame.size.width,
          self.window.frame.size.height);

    MetalViewController *rootVC = [[MetalViewController alloc] init];
    self.window.rootViewController = rootVC;
    BXLog(@"rootViewController set");

    [self.window makeKeyAndVisible];
    BXLog(@"makeKeyAndVisible done");

    [[LogOverlay shared] installInWindow:self.window];
    BXLog(@"LogOverlay installed on window");

    return YES;
}

@end
