// AUDIT REFERENCE: Section 0-F (Category 7)
// STATUS: NEW
#import <Foundation/Foundation.h>
#include "Host.h"
#include "common/ProgressCallback.h"
#include "common/SettingsInterface.h"
#include "common/SmallString.h"
#include <mutex>

const char* Host::TranslateToCString(const std::string_view context, const std::string_view msg) { return msg.data(); }
std::string_view Host::TranslateToStringView(const std::string_view context, const std::string_view msg) { return msg; }
std::string Host::TranslateToString(const std::string_view context, const std::string_view msg) { return std::string(msg); }
std::string Host::TranslatePluralToString(const char* context, const char* msg, const char* disambiguation, int count) { return std::string(msg); }
void Host::ClearTranslationCache() {}
void Host::AddOSDMessage(std::string message, float duration) {}
void Host::AddKeyedOSDMessage(std::string key, std::string message, float duration) {}
void Host::AddIconOSDMessage(std::string key, const char* icon, const std::string_view message, float duration) {}
void Host::RemoveKeyedOSDMessage(std::string key) {}
void Host::ClearOSDMessages() {}
void Host::ReportInfoAsync(const std::string_view title, const std::string_view message) { NSLog(@"[BionicSX2] %.*s: %.*s", (int)title.size(), title.data(), (int)message.size(), message.data()); }
void Host::ReportFormattedInfoAsync(const std::string_view title, const char* format, ...) {}
void Host::ReportErrorAsync(const std::string_view title, const std::string_view message) { NSLog(@"[BionicSX2 ERROR] %.*s: %.*s", (int)title.size(), title.data(), (int)message.size(), message.data()); }
void Host::ReportFormattedErrorAsync(const std::string_view title, const char* format, ...) {}
bool Host::InBatchMode() { return false; }
bool Host::InNoGUIMode() { return false; }
void Host::OpenURL(const std::string_view url) {}
bool Host::CopyTextToClipboard(const std::string_view text) { return false; }
bool Host::RequestResetSettings(bool folders, bool core, bool controllers, bool hotkeys, bool ui) { return false; }
void Host::RequestResizeHostDisplay(s32 width, s32 height) {}
void Host::RunOnCPUThread(std::function<void()> function, bool block) { if (function) function(); }
void Host::RunOnGSThread(std::function<void()> function) { if (function) function(); }
void Host::RefreshGameListAsync(bool invalidate_cache) {}
void Host::CancelGameListRefresh() {}
void Host::RequestVMShutdown(bool allow_confirm, bool allow_save_state, bool default_save_state) {}
std::string Host::GetHTTPUserAgent() { return "BionicSX2/0.1.0"; }

std::string Host::GetBaseStringSettingValue(const char* section, const char* key, const char* default_value) { return default_value ? std::string(default_value) : std::string(); }
SmallString Host::GetBaseSmallStringSettingValue(const char* section, const char* key, const char* default_value) { SmallString s; if (default_value) s = default_value; return s; }
TinyString Host::GetBaseTinyStringSettingValue(const char* section, const char* key, const char* default_value) { TinyString s; if (default_value) s = default_value; return s; }
bool Host::GetBaseBoolSettingValue(const char* section, const char* key, bool default_value) { return default_value; }
int Host::GetBaseIntSettingValue(const char* section, const char* key, int default_value) { return default_value; }
uint Host::GetBaseUIntSettingValue(const char* section, const char* key, uint default_value) { return default_value; }
float Host::GetBaseFloatSettingValue(const char* section, const char* key, float default_value) { return default_value; }
double Host::GetBaseDoubleSettingValue(const char* section, const char* key, double default_value) { return default_value; }
std::vector<std::string> Host::GetBaseStringListSetting(const char* section, const char* key) { return {}; }
void Host::SetBaseBoolSettingValue(const char* section, const char* key, bool value) {}
void Host::SetBaseIntSettingValue(const char* section, const char* key, int value) {}
void Host::SetBaseUIntSettingValue(const char* section, const char* key, uint value) {}
void Host::SetBaseFloatSettingValue(const char* section, const char* key, float value) {}
void Host::SetBaseStringSettingValue(const char* section, const char* key, const char* value) {}
void Host::SetBaseStringListSettingValue(const char* section, const char* key, const std::vector<std::string>& values) {}
bool Host::AddBaseValueToStringList(const char* section, const char* key, const char* value) { return false; }
bool Host::RemoveBaseValueFromStringList(const char* section, const char* key, const char* value) { return false; }
bool Host::ContainsBaseSettingValue(const char* section, const char* key) { return false; }
void Host::RemoveBaseSettingValue(const char* section, const char* key) {}
void Host::CommitBaseSettingChanges() {}

std::string Host::GetStringSettingValue(const char* section, const char* key, const char* default_value) { return default_value ? std::string(default_value) : std::string(); }
SmallString Host::GetSmallStringSettingValue(const char* section, const char* key, const char* default_value) { SmallString s; if (default_value) s = default_value; return s; }
TinyString Host::GetTinyStringSettingValue(const char* section, const char* key, const char* default_value) { TinyString s; if (default_value) s = default_value; return s; }
bool Host::GetBoolSettingValue(const char* section, const char* key, bool default_value) { return default_value; }
int Host::GetIntSettingValue(const char* section, const char* key, int default_value) { return default_value; }
uint Host::GetUIntSettingValue(const char* section, const char* key, uint default_value) { return default_value; }
float Host::GetFloatSettingValue(const char* section, const char* key, float default_value) { return default_value; }
double Host::GetDoubleSettingValue(const char* section, const char* key, double default_value) { return default_value; }
std::vector<std::string> Host::GetStringListSetting(const char* section, const char* key) { return {}; }

std::unique_lock<std::mutex> Host::GetSettingsLock() { static std::mutex m; return std::unique_lock<std::mutex>(m); }
std::unique_lock<std::mutex> Host::GetSecretsSettingsLock() { static std::mutex m; return std::unique_lock<std::mutex>(m); }
SettingsInterface* Host::GetSettingsInterface() { return nullptr; }
void Host::SetDefaultUISettings(SettingsInterface& si) {}
std::unique_ptr<ProgressCallback> Host::CreateHostProgressCallback() { return nullptr; }
int Host::LocaleSensitiveCompare(std::string_view lhs, std::string_view rhs) { return 0; }

namespace Host { namespace Internal {
SettingsInterface* GetBaseSettingsLayer() { return nullptr; }
SettingsInterface* GetSecretsSettingsLayer() { return nullptr; }
SettingsInterface* GetGameSettingsLayer() { return nullptr; }
SettingsInterface* GetInputSettingsLayer() { return nullptr; }
void SetBaseSettingsLayer(SettingsInterface* sif) {}
void SetSecretsSettingsLayer(SettingsInterface* sif) {}
void SetGameSettingsLayer(SettingsInterface* sif, std::unique_lock<std::mutex>& settings_lock) {}
void SetInputSettingsLayer(SettingsInterface* sif, std::unique_lock<std::mutex>& settings_lock) {}
s32 GetTranslatedStringImpl(const std::string_view context, const std::string_view msg, char* tbuf, size_t tbuf_space) { return 0; }
}}
