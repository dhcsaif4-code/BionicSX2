#import "AppDelegate.h"
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

    BXLog(@"Returning YES — scene creation follows");
    return YES;
}

- (UISceneConfiguration*)application:(UIApplication*)application
    configurationForConnectingSceneSession:(UISceneSession*)session
                                   options:(UISceneConnectionOptions*)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:session.role];
}

@end
