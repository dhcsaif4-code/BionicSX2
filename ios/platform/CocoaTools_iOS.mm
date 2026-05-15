// PORTED FROM: common/CocoaTools.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.3, 1.3
// STATUS: YELLOW
#if ! __has_feature(objc_arc)
	#error "Compile this with -fobjc-arc"
#endif

#include "CocoaTools.h"
#include "Console.h"
#include "HostSys.h"
#include "WindowInfo.h"
#include <mutex>
#include <vector>
#include <UIKit/UIKit.h>     // PORTED: AppKit removed, UIKit added (Audit Section 4.3)
#include <QuartzCore/QuartzCore.h>

static NSString*_Nonnull NSStringFromStringView(std::string_view sv)
{
	return [[NSString alloc] initWithBytes:sv.data() length:sv.size() encoding:NSUTF8StringEncoding];
}

bool CocoaTools::CreateMetalLayer(WindowInfo* wi)
{
	if (![NSThread isMainThread])
	{
		bool ret;
		dispatch_sync(dispatch_get_main_queue(), [&ret, wi]{ ret = CreateMetalLayer(wi); });
		return ret;
	}

	CAMetalLayer* layer = [CAMetalLayer layer];
	if (!layer)
	{
		Console.Error("Failed to create Metal layer.");
		return false;
	}

	// PORTED: NSView → UIView (Audit Section 4.3)
	UIView* view = (__bridge UIView*)wi->window_handle;
	[view setLayer:layer];
	[layer setContentsScale:[[UIScreen mainScreen] scale]];
	wi->surface_handle = (__bridge_retained void*)layer;
	return true;
}

void CocoaTools::DestroyMetalLayer(WindowInfo* wi)
{
	if (![NSThread isMainThread])
	{
		dispatch_sync_f(dispatch_get_main_queue(), wi, [](void* ctx){ DestroyMetalLayer(static_cast<WindowInfo*>(ctx)); });
		return;
	}

	// PORTED: NSView → UIView (Audit Section 4.3)
	UIView* view = (__bridge UIView*)wi->window_handle;
	CAMetalLayer* layer = (__bridge_transfer CAMetalLayer*)wi->surface_handle;
	if (!layer)
		return;
	wi->surface_handle = nullptr;
}

std::optional<float> CocoaTools::GetViewRefreshRate(const WindowInfo& wi)
{
	if (![NSThread isMainThread])
	{
		std::optional<float> ret;
		dispatch_sync(dispatch_get_main_queue(), [&ret, wi]{ ret = GetViewRefreshRate(wi); });
		return ret;
	}

	// PORTED: UIScreen maximumFramesPerSecond (Audit Section 4.3)
	return static_cast<float>([[UIScreen mainScreen] maximumFramesPerSecond]);
}

void CocoaTools::MarkHelpMenu(void* menu)
{
	// PORTED: No-op on iOS — no NSMenu (Audit Section 4.3)
}

bool Common::PlaySoundAsync(const char* path)
{
	// PORTED: Use AVAudioPlayer on iOS
	NSString* nspath = [[NSString alloc] initWithUTF8String:path];
	NSURL* url = [NSURL fileURLWithPath:nspath];
	AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	return [player play];
}

std::optional<std::string> CocoaTools::GetBundlePath()
{
	std::optional<std::string> ret;
	@autoreleasepool {
		NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
		if (url)
			ret = std::string([url fileSystemRepresentation]);
	}
	return ret;
}

std::optional<std::string> CocoaTools::GetNonTranslocatedBundlePath()
{
	// PORTED: No translocation on iOS (Audit Section 4.3)
	return CocoaTools::GetBundlePath();
}

std::optional<std::string> CocoaTools::MoveToTrash(std::string_view file)
{
	// PORTED: iOS uses NSFileManager trashItemAtURL
	NSURL* url = [NSURL fileURLWithPath:NSStringFromStringView(file)];
	NSURL* new_url;
	if (![[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:&new_url error:nil])
		return std::nullopt;
	return std::string([new_url fileSystemRepresentation]);
}

bool CocoaTools::ShowInFinder(std::string_view file)
{
	// PORTED: No Finder on iOS — no-op
	return false;
}

std::optional<std::string> CocoaTools::GetResourcePath()
{
	@autoreleasepool {
		if (NSBundle* bundle = [NSBundle mainBundle])
		{
			NSString* rsrc = [bundle resourcePath];
			return [rsrc UTF8String];
		}
		return std::nullopt;
	}
}

void* CocoaTools::CreateWindow(std::string_view title, u32 width, u32 height)
{
	// PORTED: iOS uses UIWindow, not NSWindow (Audit Section 4.3)
	UIWindow* window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	window.backgroundColor = [UIColor blackColor];
	return (__bridge_retained void*)window;
}

void CocoaTools::DestroyWindow(void* window)
{
	(void)(__bridge_transfer UIWindow*)window;
}

void CocoaTools::GetWindowInfoFromWindow(WindowInfo* wi, void* cf_window)
{
	if (cf_window)
	{
		// PORTED: NSWindow → UIWindow (Audit Section 4.3)
		UIWindow* window = (__bridge UIWindow*)cf_window;
		float scale = [window screen].scale;
		UIView* view = window.rootViewController.view;
		CGRect dims = [view frame];
		wi->type = WindowInfo::Type::MacOS;
		wi->window_handle = (__bridge void*)view;
		wi->surface_width = dims.size.width * scale;
		wi->surface_height = dims.size.height * scale;
		wi->surface_scale = scale;
	}
	else
	{
		wi->type = WindowInfo::Type::Surfaceless;
	}
}

void CocoaTools::RunCocoaEventLoop(bool forever)
{
	// PORTED: No-op — iOS has its own UIApplication run loop (Audit Section 4.3)
}

void CocoaTools::StopMainThreadEventLoop()
{
	// PORTED: No-op — iOS run loop is managed by UIApplication
}
