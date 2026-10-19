#ifndef RUNNER_PLATFORM_BRIDGE_H_
#define RUNNER_PLATFORM_BRIDGE_H_

#include <windows.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <memory>

class PlatformBridge {
 public:
  PlatformBridge(HWND window, flutter::BinaryMessenger* messenger);
  ~PlatformBridge();
  bool HandleMessage(UINT message, WPARAM wparam, LPARAM lparam);

 private:
  void RemoveNotification();
  HWND window_;
  bool notification_visible_ = false;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_PLATFORM_BRIDGE_H_
