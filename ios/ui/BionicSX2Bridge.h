// AUDIT REFERENCE: Section 8.3, 4.3
// STATUS: NEW
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

// Pad button constants matching PS2 pad (AUDIT Sec 2.7)
extern const int PAD_CROSS;
extern const int PAD_CIRCLE;
extern const int PAD_SQUARE;
extern const int PAD_TRIANGLE;
extern const int PAD_L1;
extern const int PAD_R1;
extern const int PAD_L2;
extern const int PAD_R2;
extern const int PAD_UP;
extern const int PAD_DOWN;
extern const int PAD_LEFT;
extern const int PAD_RIGHT;

@interface BionicSX2Bridge : NSObject
+ (BOOL)startVMWithISO:(NSString* _Nullable)isoPath;
+ (void)stopVM;
+ (void)setMetalLayer:(CAMetalLayer* _Nonnull)layer;
+ (void)setPadButton:(int)pad button:(int)button pressed:(BOOL)pressed;
+ (void)setAnalogStick:(int)pad stick:(int)stick x:(float)x y:(float)y;
+ (void)clearPadState:(int)pad;
@end
