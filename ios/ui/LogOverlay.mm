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

// ── Async-signal-safe helpers for SA_SIGINFO reporting ────────────────
static void SafeWriteRaw(const char* s, size_t len) {
    if (g_crashLogFd < 0) return;
    size_t written = 0;
    while (written < len) {
        ssize_t n = write(g_crashLogFd, s + written, len - written);
        if (n <= 0) break;
        written += (size_t)n;
    }
    fsync(g_crashLogFd);
}

static void SafeWriteStr(const char* s) {
    size_t len = 0;
    while (s[len]) len++;
    SafeWriteRaw(s, len);
}

static void SafeWriteHex64(const char* label, uint64_t val) {
    SafeWriteStr(label);
    SafeWriteRaw(" 0x", 3);
    char buf[16];
    for (int i = 15; i >= 0; i--) {
        unsigned digit = (unsigned)(val & 0xF);
        buf[i] = (digit < 10) ? (char)('0' + digit) : (char)('a' + digit - 10);
        val >>= 4;
    }
    SafeWriteRaw(buf, 16);
    SafeWriteRaw("\n", 1);
}

// ── SA_SIGINFO handler for SIGSEGV (captures fault addr + PC) ─────────
static void SigsegvHandler(int sig, siginfo_t* info, void* ucontext) {
    SafeWriteTimestamp();
    SafeWriteStr("FATAL CRASH: SIGSEGV (invalid memory access)\n");

    uint64_t fault_addr = (uint64_t)(uintptr_t)(info->si_addr);
    SafeWriteHex64("fault addr", fault_addr);

    // Extract PC from ARM64 ucontext
#if defined(__arm64__)
    ucontext_t* uc = (ucontext_t*)ucontext;
    uint64_t pc = (uint64_t)uc->uc_mcontext->__ss.__pc;
#else
    uint64_t pc = 0;
#endif
    SafeWriteHex64("pc", pc);

    // Reset to default and re-raise so the OS generates a crash report
    signal(sig, SIG_DFL);
    raise(sig);
}

// ── Plain signal handler for non-SEGV signals ─────────────────────────
static void CrashSignalHandler(int sig) {
    const char* name = nullptr;
    switch (sig) {
        case SIGABRT: name = "SIGABRT (abort)"; break;
        case SIGBUS:  name = "SIGBUS (bus error)"; break;
        case SIGILL:  name = "SIGILL (illegal instruction)"; break;
        case SIGFPE:  name = "SIGFPE (floating point exception)"; break;
        default:      name = "UNKNOWN SIGNAL"; break;
    }
    SafeWriteTimestamp();
    SafeWriteStr("FATAL CRASH: ");
    SafeWriteStr(name);
    SafeWriteStr("\n");
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
    // SIGSEGV uses sigaction with SA_SIGINFO for fault address + PC
    {
        struct sigaction sa;
        memset(&sa, 0, sizeof(sa));
        sa.sa_sigaction = SigsegvHandler;
        sa.sa_flags = SA_SIGINFO | SA_NODEFER;
        sigemptyset(&sa.sa_mask);
        sigaction(SIGSEGV, &sa, NULL);
    }
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



void BXLog(NSString* format, ...) {
    va_list args;
    va_start(args, format);
    NSString* msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSString* ts = Timestamp();
    NSString* fileLine = [NSString stringWithFormat:@"[%@] %@\n", ts, msg];
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

        // Mark new session in file via crash-safe fd
        NSString* ts = Timestamp();
        NSString* session = [NSString stringWithFormat:@"[%@] ===== APP STARTED =====\n", ts];
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
