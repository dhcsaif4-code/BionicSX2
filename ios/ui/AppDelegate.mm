#import "AppDelegate.h"
#include "LogOverlay.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    // Initialize crash-safe logger before anything else
    [LogOverlay shared];
    BXLog(@"App launched — application:didFinishLaunchingWithOptions");
    self.window = [[UIWindow alloc] initWithFrame:
                   UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
