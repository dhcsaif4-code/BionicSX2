#import <UIKit/UIKit.h>
#include "pcsx2/Host.h"
#include "pcsx2/VMManager.h"
#include "pcsx2/Input/InputManager.h"

namespace Host {
  void OnVMStarting() {}
  void OnVMStarted() {}
  void OnVMDestroyed() {}
  void OnVMPaused() {}
  void OnVMResumed() {}
  void OnGameChanged(const std::string&, const std::string&,
    const std::string&, const std::string&, u32, u32) {}
  void OnPerformanceMetricsUpdated() {}
  void OnSaveStateSaved(std::string_view) {}
  void OnSaveStateLoading(std::string_view) {}
  void OnSaveStateLoaded(std::string_view, bool) {}
  void OnCaptureStarted(const std::string&) {}
  void OnCaptureStopped() {}
  void OnAchievementsRefreshed() {}
  void OnAchievementsLoginSuccess(const char*, u32, u32, u32) {}
  void OnAchievementsLoginRequested(Achievements::LoginRequestReason) {}
  void OnAchievementsHardcoreModeChanged(bool) {}
  void OnInputDeviceConnected(std::string_view, std::string_view) {}
  void OnInputDeviceDisconnected(InputBindingKey, std::string_view) {}
  void OnCoverDownloaderOpenRequested() {}
  bool IsFullscreen() { return true; }
  void SetFullscreen(bool) {}
  bool AcquireRenderWindow(bool) { return true; }
  void ReleaseRenderWindow() {}
  void BeginPresentFrame() {}
  void RequestExitApplication(bool) {}
  void RequestExitBigPicture() {}
  void CheckForSettingsChanges(const Pcsx2Config&) {}
  void LoadSettings(SettingsInterface&, std::unique_lock<std::mutex>&) {}
  void PumpMessagesOnCPUThread() {}
  void BeginTextInput() {}
  void EndTextInput() {}
  void SetMouseMode(bool, bool) {}
  void SetMouseLock(bool) {}
  bool LocaleCircleConfirm() { return false; }
  std::string GetHTTPUserAgent() { return "BionicSX2/1.0"; }
  void OpenURL(const std::string_view) {}
  bool CopyTextToClipboard(const std::string_view) { return false; }
}

BEGIN_HOTKEY_LIST(g_host_hotkeys)
END_HOTKEY_LIST()
