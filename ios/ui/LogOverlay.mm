#include "LogOverlay.h"
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <pthread.h>
#include <cstring>
#include <cstdio>

static LogOverlay* g_shared = nil;
static UITextView* g_textView = nil;
static NSMutableArray* g_screenLines = nil;
static NSString* g_logPath = nil;

// ── Crash-safe file descriptor (opened once, used by signal handlers) ──
static int g_crashLogFd = -1;
static pthread_mutex_t g_crashLogMutex = PTHREAD_MUTEX_INITIALIZER;

void BXSX2SafeWriteToLog(const char* msg) {
    if (g_crashLogFd < 0) return;
    // Write in a loop to handle partial writes
    size_t len = strlen(msg);
    const char* p = msg;
    while (len > 0) {
        ssize_t written = write(g_crashLogFd, p, len);
        if (written <= 0) break;
        p += written;
        len -= static_cast<size_t>(written);
    }
    fsync(g_crashLogFd);
}

static void SafeWriteTimestamp() {
    struct timespec ts;
    struct tm local;
    char buf[64];
    clock_gettime(CLOCK_REALTIME, &ts);
    localtime_r(&ts.tv_sec, &local);
    strftime(buf, sizeof(buf), "[%H:%M:%S] ", &local);
    BXSX2SafeWriteToLog(buf);
}

// ── Signal handlers (async-signal-safe only) ───────────────────────────
static void CrashSignalHandler(int sig) {
    const char* name = nullptr;
    switch (sig) {
        case SIGSEGV: name = "SIGSEGV (invalid memory access)"; break;
        case SIGABRT: name = "SIGABRT (abort)"; break;
        case SIGBUS:  name = "SIGBUS (bus error)"; break;
        case SIGILL:  name = "SIGILL (illegal instruction)"; break;
        case SIGFPE:  name = "SIGFPE (floating point exception)"; break;
        default:      name = "UNKNOWN SIGNAL"; break;
    }
    SafeWriteTimestamp();
    BXSX2SafeWriteToLog("FATAL CRASH: ");
    BXSX2SafeWriteToLog(name);
    BXSX2SafeWriteToLog("\n");
    // Reset to default and re-raise so the OS generates a crash report
    signal(sig, SIG_DFL);
    raise(sig);
}

// ── ObjC uncaught exception handler (not async-signal-safe, but runs before
//    the OS kills us) ─────────────────────────────────────────────────────
static void UncaughtExceptionHandler(NSException* exception) {
    NSString* msg = [NSString stringWithFormat:
        @"UNCAUGHT EXCEPTION: %@ — %@\n  %@",
        exception.name, exception.reason,
        [[exception callStackSymbols] componentsJoinedByString:@"\n  "]];
    NSLog(@"%@", msg);
    BXSX2SafeWriteToLog([[msg stringByAppendingString:@"\n"] UTF8String]);
}

void BXSX2InstallCrashHandlers(void) {
    if (g_crashLogFd >= 0) return; // already installed

    // Open log file for crash-safe writing
    NSString* docs = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [docs stringByAppendingPathComponent:@"runtime.log"];
    g_logPath = path;

    const char* cpath = [path UTF8String];
    g_crashLogFd = open(cpath, O_WRONLY | O_CREAT | O_APPEND, 0644);

    // Install signal handlers (async-signal-safe)
    signal(SIGSEGV, CrashSignalHandler);
    signal(SIGABRT, CrashSignalHandler);
    signal(SIGBUS, CrashSignalHandler);
    signal(SIGILL, CrashSignalHandler);
    signal(SIGFPE, CrashSignalHandler);

    // Install ObjC uncaught exception handler
    NSSetUncaughtExceptionHandler(UncaughtExceptionHandler);
}

static NSString* Timestamp() {
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";
    return [fmt stringFromDate:[NSDate date]];
}

static void WriteToFile(NSString* line) {
    if (!g_logPath) return;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:g_logPath];
    if (!fh) {
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
    // Also write through crash-safe fd
    BXSX2SafeWriteToLog([fileLine UTF8String]);
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
    BXSX2SafeWriteToLog([fileLine UTF8String]);
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
        // If crash handlers were not installed earlier, install now
        if (g_crashLogFd < 0)
            BXSX2InstallCrashHandlers();

        // Mark new session in file via WriteToFile (NSFileHandle)
        NSString* ts = Timestamp();
        NSString* session = [NSString stringWithFormat:@"[%@] ===== APP STARTED =====\n", ts];
        WriteToFile(session);
        // Also write through crash-safe fd
        BXSX2SafeWriteToLog([session UTF8String]);

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
