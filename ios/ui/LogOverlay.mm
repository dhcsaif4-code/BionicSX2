#include "LogOverlay.h"

static LogOverlay* g_shared = nil;
static UITextView* g_textView = nil;
static NSMutableArray* g_screenLines = nil;
static NSString* g_logPath = nil;

static NSString* Timestamp() {
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";
    return [fmt stringFromDate:[NSDate date]];
}

static void WriteToFile(NSString* line) {
    if (!g_logPath) return;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:g_logPath];
    if (!fh) {
        // First write — create file
        [[NSFileManager defaultManager] createFileAtPath:g_logPath contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:g_logPath];
        if (!fh) return;
    }
    [fh seekToEndOfFile];
    NSData* data = [line dataUsingEncoding:NSUTF8StringEncoding];
    [fh writeData:data];
    [fh synchronizeFile];
    [fh closeFile];
}

void BXLog(NSString* format, ...) {
    va_list args;
    va_start(args, format);
    NSString* msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSString* ts = Timestamp();
    NSString* fileLine = [NSString stringWithFormat:@"[%@] %@\n", ts, msg];
    WriteToFile(fileLine);
    NSLog(@"[BionicSX2] %@", msg);
    [[LogOverlay shared] addEntry:msg isError:NO];
}

void BXLogError(NSString* format, ...) {
    va_list args;
    va_start(args, format);
    NSString* msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSString* ts = Timestamp();
    NSString* fileLine = [NSString stringWithFormat:@"[%@] ERROR: %@\n", ts, msg];
    WriteToFile(fileLine);
    NSLog(@"[BionicSX2] ERROR: %@", msg);
    [[LogOverlay shared] addEntry:msg isError:YES];
}

@implementation LogOverlay

+ (instancetype)shared {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        g_shared = [[LogOverlay alloc] init];
    });
    return g_shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Determine log path in Documents directory
        NSString* docs = NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        g_logPath = [docs stringByAppendingPathComponent:@"runtime.log"];

        // Mark new session
        NSString* ts = Timestamp();
        NSString* session = [NSString stringWithFormat:@"[%@] ===== APP STARTED =====\n", ts];
        WriteToFile(session);

        g_textView = [[UITextView alloc] initWithFrame:CGRectZero];
        g_textView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        g_textView.textColor = [UIColor whiteColor];
        g_textView.font = [UIFont fontWithName:@"Menlo" size:10];
        g_textView.editable = NO;
        g_textView.selectable = NO;
        g_textView.scrollEnabled = YES;
        g_textView.showsVerticalScrollIndicator = YES;
        g_textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
        g_textView.userInteractionEnabled = YES;
        g_textView.hidden = NO;

        g_screenLines = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)installInWindow:(UIWindow*)window {
    if (!window || g_textView.superview) return;

    g_textView.translatesAutoresizingMaskIntoConstraints = NO;
    [window addSubview:g_textView];
    [window bringSubviewToFront:g_textView];

    [NSLayoutConstraint activateConstraints:@[
        [g_textView.topAnchor constraintEqualToAnchor:window.safeAreaLayoutGuide.topAnchor],
        [g_textView.leadingAnchor constraintEqualToAnchor:window.leadingAnchor],
        [g_textView.trailingAnchor constraintEqualToAnchor:window.trailingAnchor],
        [g_textView.heightAnchor constraintEqualToConstant:220]
    ]];
}

- (void)addEntry:(NSString*)entry isError:(BOOL)isError {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!g_textView || !g_screenLines) return;

        NSString* ts = Timestamp();
        NSString* screenLine = [NSString stringWithFormat:@"[%@] %@", ts, entry];

        [g_screenLines addObject:screenLine];

        // Keep only last 20 lines
        while (g_screenLines.count > 20)
            [g_screenLines removeObjectAtIndex:0];

        g_textView.text = [g_screenLines componentsJoinedByString:@"\n"];

        if (isError) {
            g_textView.textColor = [UIColor redColor];
        } else {
            g_textView.textColor = [UIColor whiteColor];
        }

        // Scroll to bottom
        NSRange bottom = NSMakeRange(g_textView.text.length - 1, 1);
        if (bottom.location != NSNotFound)
            [g_textView scrollRangeToVisible:bottom];
    });
}

@end
