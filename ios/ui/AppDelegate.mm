#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:
                   UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
