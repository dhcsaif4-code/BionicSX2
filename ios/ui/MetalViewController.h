#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

@interface MetalViewController : UIViewController
@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end
