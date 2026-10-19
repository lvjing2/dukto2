#include "platform_bridge.h"

#include <flutter/standard_method_codec.h>
#include <shellapi.h>
#include <shlobj.h>
#include <iterator>
#include <string>

#include "resource.h"
#include "utils.h"

namespace {
constexpr UINT kNotificationMessage = WM_APP + 0xD2;
constexpr UINT_PTR kNotificationTimer = 0xD2F1;
constexpr UINT kNotificationId = 1;
using Value = flutter::EncodableValue;

std::wstring Wide(const std::string& text) {
  if (text.empty() || text.size() > 32767 || text.find('\0') != std::string::npos) {
    return {};
  }
  const int length = static_cast<int>(text.size());
  const int size = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
                                      text.data(), length, nullptr, 0);
  if (size == 0) return {};
  std::wstring result(static_cast<size_t>(size), L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, text.data(), length,
                      result.data(), size);
  return result;
}

std::wstring Argument(const Value* args, const char* key) {
  const auto* map = args ? std::get_if<flutter::EncodableMap>(args) : nullptr;
  if (!map) return {};
  const auto found = map->find(Value(key));
  if (found == map->end()) return {};
  const auto* value = std::get_if<std::string>(&found->second);
  return value ? Wide(*value) : std::wstring();
}
}  // namespace

PlatformBridge::PlatformBridge(HWND window, flutter::BinaryMessenger* messenger)
    : window_(window) {
  channel_ = std::make_unique<flutter::MethodChannel<Value>>(
      messenger, "dukto2/platform", &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<Value>& call,
             std::unique_ptr<flutter::MethodResult<Value>> result) {
        const auto& method = call.method_name();
        if (method == "getDeviceName") {
          wchar_t name[256] = {};
          DWORD size = static_cast<DWORD>(std::size(name));
          if (!GetComputerNameExW(ComputerNamePhysicalDnsHostname, name, &size)) {
            result->Error("DEVICE_NAME", "Cannot read Windows computer name");
            return;
          }
          result->Success(Value(Utf8FromUtf16(name)));
        } else if (method == "keepAwake") {
          const auto* active = call.arguments()
              ? std::get_if<bool>(call.arguments()) : nullptr;
          if (SetThreadExecutionState(ES_CONTINUOUS |
                  ((active && *active) ? ES_SYSTEM_REQUIRED : 0)) == 0) {
            result->Error("POWER", "Cannot update idle sleep request");
            return;
          }
          result->Success();
        } else if (method == "openHistoryDirectory") {
          const auto path = Argument(call.arguments(), "path");
          if (path.empty() || GetFileAttributesW(path.c_str()) == INVALID_FILE_ATTRIBUTES) {
            result->Error("DIRECTORY", "File moved, deleted, or no longer accessible");
            return;
          }
          PIDLIST_ABSOLUTE item = nullptr;
          HRESULT status = SHParseDisplayName(path.c_str(), nullptr, &item, 0, nullptr);
          if (SUCCEEDED(status)) {
            // cidl=0 opens the parent and selects this fully qualified item.
            status = SHOpenFolderAndSelectItems(item, 0, nullptr, 0);
          }
          CoTaskMemFree(item);
          if (FAILED(status)) {
            result->Error("DIRECTORY", "Cannot show file in Explorer");
            return;
          }
          result->Success();
        } else if (method == "notificationStatus" || method == "requestNotifications") {
          // Classic Win32 notifications do not have Apple's permission prompt.
          // Do not claim that Windows/Focus Assist has granted delivery.
          result->Success(Value("managed"));
        } else if (method == "openNotificationSettings") {
          const auto opened = reinterpret_cast<INT_PTR>(ShellExecuteW(
              window_, L"open", L"ms-settings:notifications", nullptr, nullptr, SW_SHOWNORMAL));
          if (opened <= 32) {
            result->Error("NOTIFICATIONS", "Cannot open Windows notification settings");
            return;
          }
          result->Success();
        } else if (method == "notifyComplete") {
          QUERY_USER_NOTIFICATION_STATE state;
          if (FAILED(SHQueryUserNotificationState(&state)) ||
              state != QUNS_ACCEPTS_NOTIFICATIONS) {
            result->Success();
            return;
          }
          RemoveNotification();
          NOTIFYICONDATAW data = {};
          data.cbSize = sizeof(data);
          data.hWnd = window_;
          data.uID = kNotificationId;
          data.uFlags = NIF_ICON | NIF_TIP | NIF_MESSAGE;
          data.uCallbackMessage = kNotificationMessage;
          data.hIcon = LoadIconW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(IDI_APP_ICON));
          wcscpy_s(data.szTip, L"Dukto2");
          if (!Shell_NotifyIconW(NIM_ADD, &data)) {
            result->Error("NOTIFICATIONS", "Cannot create completion notification");
            return;
          }
          notification_visible_ = true;
          data.uFlags = NIF_INFO | NIF_REALTIME;
          data.dwInfoFlags = NIIF_INFO | NIIF_RESPECT_QUIET_TIME;
          const auto title = Argument(call.arguments(), "title");
          const auto body = Argument(call.arguments(), "body");
          wcsncpy_s(data.szInfoTitle, title.c_str(), _TRUNCATE);
          wcsncpy_s(data.szInfo, body.c_str(), _TRUNCATE);
          if (!Shell_NotifyIconW(NIM_MODIFY, &data)) {
            RemoveNotification();
            result->Error("NOTIFICATIONS", "Cannot display completion notification");
            return;
          }
          SetTimer(window_, kNotificationTimer, 45000, nullptr);
          result->Success();
        } else {
          result->NotImplemented();
        }
      });
}

PlatformBridge::~PlatformBridge() {
  channel_->SetMethodCallHandler(nullptr);
  RemoveNotification();
  SetThreadExecutionState(ES_CONTINUOUS);
}

void PlatformBridge::RemoveNotification() {
  KillTimer(window_, kNotificationTimer);
  if (!notification_visible_) return;
  NOTIFYICONDATAW data = {};
  data.cbSize = sizeof(data);
  data.hWnd = window_;
  data.uID = kNotificationId;
  Shell_NotifyIconW(NIM_DELETE, &data);
  notification_visible_ = false;
}

bool PlatformBridge::HandleMessage(UINT message, WPARAM wparam, LPARAM lparam) {
  if (message == WM_TIMER && wparam == kNotificationTimer) {
    RemoveNotification();
    return true;
  }
  if (message != kNotificationMessage) return false;
  if (lparam == NIN_BALLOONUSERCLICK || lparam == WM_LBUTTONUP) {
    ShowWindow(window_, SW_RESTORE);
    SetForegroundWindow(window_);
  }
  if (lparam == NIN_BALLOONHIDE || lparam == NIN_BALLOONTIMEOUT ||
      lparam == NIN_BALLOONUSERCLICK || lparam == WM_LBUTTONUP) {
    RemoveNotification();
  }
  return true;
}
