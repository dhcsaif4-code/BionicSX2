#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

void BXLog(NSString* format, ...);
void BXLogError(NSString* format, ...);

#ifdef __cplusplus
}
#endif

@interface LogOverlay : NSObject
+ (instancetype)shared;
- (void)installInWindow:(UIWindow*)window;
- (void)addEntry:(NSString*)entry isError:(BOOL)isError;
@end
