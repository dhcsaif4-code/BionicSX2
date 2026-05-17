#import "MetalViewController.h"
#import "BionicSX2Bridge.h"
#include "LogOverlay.h"

@implementation MetalViewController

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BXLog(@"Step 1 — viewDidLoad entered");

    CAMetalLayer *layer = (CAMetalLayer *)self.view.layer;
    if (!layer) {
        BXLogError(@"Step 2 FAILED: view.layer is not CAMetalLayer");
        return;
    }
    self.metalLayer = layer;
    BXLog(@"Step 2 OK — CAMetalLayer from view.layer");

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        BXLogError(@"Step 3 FAILED: MTLCreateSystemDefaultDevice returned nil");
        return;
    }
    layer.device = device;
    BXLog(@"Step 3 OK — Metal device: %s", device.name.UTF8String);

    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    layer.framebufferOnly = YES;
    layer.frame = self.view.bounds;
    layer.opaque = YES;
    BXLog(@"Step 4 OK — layer configured");

    [BionicSX2Bridge setMetalLayer:layer];
    BXLog(@"Step 5 OK — setMetalLayer on bridge");

    NSString *isoPath = [self findFirstISO];
    if (isoPath) {
        BXLog(@"Step 6 — ISO found: %s", isoPath.UTF8String);
    } else {
        BXLog(@"Step 6 — no ISO found, running without disc");
    }

    BXLog(@"Step 7 — calling startVM...");
    if ([BionicSX2Bridge startVMWithISO:isoPath]) {
        BXLog(@"Step 7 OK — VM started, surface created");

        BXLog(@"Step 8 — starting displayLink render loop");
        self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                       selector:@selector(renderFrame)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSRunLoopCommonModes];
        BXLog(@"viewDidLoad complete — render loop running");
    } else {
        BXLogError(@"Step 7 FAILED: startVM returned false — Surface FAILED");
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"VM Start Failed"
                            message:@"The emulator could not start.\n\n"
            @"Place a PS2 BIOS file (e.g. SCPH-39001.bin) in:\n"
            @"Files App → BionicSX2 → BIOS/\n\n"
            @"Check runtime.log in Documents/ for details."
                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CAMetalLayer *ml = self.metalLayer;
    if (ml) {
        ml.frame = self.view.bounds;
        CGFloat scale = self.view.contentScaleFactor;
        ml.drawableSize = CGSizeMake(self.view.bounds.size.width * scale,
                                     self.view.bounds.size.height * scale);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)renderFrame {
    CAMetalLayer *ml = self.metalLayer;
    id<CAMetalDrawable> drawable = [ml nextDrawable];
    if (!drawable) return;

    id<MTLDevice> device = ml.device;
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];

    MTLRenderPassDescriptor *passDesc = [MTLRenderPassDescriptor renderPassDescriptor];
    passDesc.colorAttachments[0].texture = drawable.texture;
    passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDesc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:passDesc];
    if (encoder) {
        [encoder endEncoding];
    }

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (NSString *)findFirstISO {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = paths.firstObject ?: @"";
    NSString *gamesDir = [docDir stringByAppendingPathComponent:@"Games"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:gamesDir error:nil];
    for (NSString *file in files) {
        if ([file hasSuffix:@".iso"] || [file hasSuffix:@".chd"] || [file hasSuffix:@".cso"]) {
            return [gamesDir stringByAppendingPathComponent:file];
        }
    }
    return nil;
}

@end
