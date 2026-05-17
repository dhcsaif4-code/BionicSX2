#import "AppDelegate.h"
#include "LogOverlay.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    // CRASH HANDLERS: Install BEFORE anything else so crashes during
    // setup are captured to runtime.log
    @try {
        BXSX2InstallCrashHandlers();
        BXSX2SafeWriteToLog("[00:00:00] Step 0 — crash handlers installed\n");

        // Step 1: initialize LogOverlay singleton (writes "===== APP STARTED =====")
        [LogOverlay shared];
        BXLog(@"Step 1 — LogOverlay initialized");

        // Step 2: create initial window
        BXLog(@"Step 2 — creating initial UIWindow");
        self.window = [[UIWindow alloc] initWithFrame:
                       UIScreen.mainScreen.bounds];
        if (!self.window) {
            BXLogError(@"Step 2 FAILED — UIWindow alloc returned nil");
        } else {
            BXLog(@"Step 2 OK — window frame: %.0fx%.0f",
                  self.window.frame.size.width,
                  self.window.frame.size.height);
        }

        // Step 3: make window key and visible
        BXLog(@"Step 3 — makeKeyAndVisible");
        [self.window makeKeyAndVisible];
        BXLog(@"Step 3 OK — window is key and visible");

        BXLog(@"Step 4 — returning YES, app launch complete");
        return YES;
    }
    @catch (NSException* ex) {
        BXSX2SafeWriteToLog("[[ @catch in application:didFinishLaunchingWithOptions ]]\n");
        NSString* crashMsg = [NSString stringWithFormat:
            @"CRASH IN didFinishLaunchingWithOptions: %@ — %@\n  %@",
            ex.name, ex.reason,
            [[ex callStackSymbols] componentsJoinedByString:@"\n  "]];
        BXSX2SafeWriteToLog([crashMsg UTF8String]);
        NSLog(@"%@", crashMsg);
        return NO;
    }
}

@end
