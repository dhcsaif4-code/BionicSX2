#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

void BXLog(NSString* format, ...);
void BXLogError(NSString* format, ...);

/// Initialize crash-safe log file descriptor and install all crash handlers.
/// Must be called BEFORE any other logging function, ideally as the very
/// first thing in application:didFinishLaunchingWithOptions.
void BXSX2InstallCrashHandlers(void);

/// Async-signal-safe write to the crash log fd (used by signal handlers).
/// Do NOT call from normal code — use BXLog/BXLogError instead.
void BXSX2SafeWriteToLog(const char* msg);

/// Configure AVAudioSession for low-latency playback. Must be called before SPU2::Init.
void iOSConfigureAudioSession(void);

#ifdef __cplusplus
}
#endif

@interface LogOverlay : NSObject
+ (instancetype)shared;
- (void)installInWindow:(UIWindow*)window;
- (void)addEntry:(NSString*)entry isError:(BOOL)isError;
@end
