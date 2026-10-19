#include "platform_bridge.h"

#include <gio/gio.h>

struct Dukto2PlatformBridge {
  GtkApplication* application;  // Owned by the runner, which disposes this bridge.
  GtkWindow* window;  // Weak pointer: a closed window must not be dereferenced.
  FlMethodChannel* channel;
  guint inhibit_cookie;
};

namespace {
void success(FlMethodCall* call, FlValue* value = nullptr) {
  fl_method_call_respond_success(call, value, nullptr);
}

const gchar* argument(FlMethodCall* call, const gchar* key) {
  FlValue* args = fl_method_call_get_args(call);
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) return nullptr;
  FlValue* value = fl_value_lookup_string(args, key);
  return value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_STRING
             ? fl_value_get_string(value) : nullptr;
}

void folder_opened(GObject*, GAsyncResult* result, gpointer user_data) {
  g_autoptr(GError) error = nullptr;
  FlMethodCall* call = FL_METHOD_CALL(user_data);
  if (g_app_info_launch_default_for_uri_finish(result, &error)) {
    success(call);
  } else {
    fl_method_call_respond_error(call, "DIRECTORY", error->message, nullptr, nullptr);
  }
  g_object_unref(call);
}

// GNOME publishes this panel as `gnome-control-center notifications`.
// Other desktops keep their own settings UI; do not expose a dead button.
gchar* notification_settings_program() {
  const gchar* desktop = g_getenv("XDG_CURRENT_DESKTOP");
  if (desktop == nullptr) return nullptr;
  g_autofree gchar* lower = g_ascii_strdown(desktop, -1);
  if (g_strrstr(lower, "gnome") == nullptr &&
      g_strrstr(lower, "ubuntu") == nullptr &&
      g_strrstr(lower, "unity") == nullptr) return nullptr;
  return g_find_program_in_path("gnome-control-center");
}

void method_call(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  auto* bridge = static_cast<Dukto2PlatformBridge*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  if (g_str_equal(method, "getDeviceName")) {
    g_autoptr(FlValue) name = fl_value_new_string(g_get_host_name());
    success(call, name);
  } else if (g_str_equal(method, "getDeviceType")) {
    g_autoptr(FlValue) type = fl_value_new_string("computer");
    success(call, type);
  } else if (g_str_equal(method, "notificationStatus") ||
             g_str_equal(method, "requestNotifications")) {
    // The desktop notification service owns delivery and Do Not Disturb.
    g_autoptr(FlValue) status = fl_value_new_string("managed");
    success(call, status);
  } else if (g_str_equal(method, "canOpenNotificationSettings")) {
    g_autofree gchar* program = notification_settings_program();
    g_autoptr(FlValue) available = fl_value_new_bool(program != nullptr);
    success(call, available);
  } else if (g_str_equal(method, "openNotificationSettings")) {
    g_autofree gchar* program = notification_settings_program();
    if (program == nullptr) {
      fl_method_call_respond_error(call, "NOTIFICATIONS", "Open notifications in your desktop settings", nullptr, nullptr);
      return;
    }
    g_autoptr(GError) error = nullptr;
    g_autoptr(GSubprocess) process = g_subprocess_new(
        G_SUBPROCESS_FLAGS_NONE, &error, program, "notifications", nullptr);
    if (process == nullptr) {
      fl_method_call_respond_error(call, "NOTIFICATIONS", error->message, nullptr, nullptr);
      return;
    }
    success(call);
  } else if (g_str_equal(method, "notifyComplete")) {
    const gchar* title = argument(call, "title");
    const gchar* body = argument(call, "body");
    if (title == nullptr || body == nullptr) {
      fl_method_call_respond_error(call, "ARGUMENT", "Missing notification text", nullptr, nullptr);
      return;
    }
    g_autoptr(GNotification) notification = g_notification_new(title);
    g_notification_set_body(notification, body);
    g_application_send_notification(G_APPLICATION(bridge->application), "transfer-complete", notification);
    success(call);
  } else if (g_str_equal(method, "keepAwake")) {
    FlValue* active = fl_method_call_get_args(call);
    if (active == nullptr || fl_value_get_type(active) != FL_VALUE_TYPE_BOOL) {
      fl_method_call_respond_error(call, "ARGUMENT", "Expected boolean", nullptr, nullptr);
      return;
    }
    if (fl_value_get_bool(active) && bridge->inhibit_cookie == 0 && bridge->window != nullptr) {
      bridge->inhibit_cookie = gtk_application_inhibit(
          bridge->application, bridge->window,
          GTK_APPLICATION_INHIBIT_SUSPEND,
          "Dukto2 file transfer");
      if (bridge->inhibit_cookie == 0) {
        fl_method_call_respond_error(call, "POWER", "Desktop refused sleep inhibition", nullptr, nullptr);
        return;
      }
    } else if (!fl_value_get_bool(active) && bridge->inhibit_cookie != 0) {
      gtk_application_uninhibit(bridge->application, bridge->inhibit_cookie);
      bridge->inhibit_cookie = 0;
    }
    success(call);
  } else if (g_str_equal(method, "openHistoryDirectory")) {
    const gchar* path = argument(call, "path");
    if (path == nullptr || !g_path_is_absolute(path) || !g_file_test(path, G_FILE_TEST_EXISTS)) {
      fl_method_call_respond_error(call, "DIRECTORY", "File moved, deleted, or inaccessible", nullptr, nullptr);
      return;
    }
    // Open only the parent via GIO, with a file URI. Never interpolate shell code.
    g_autofree gchar* parent = g_path_get_dirname(path);
    g_autofree gchar* uri = g_filename_to_uri(parent, nullptr, nullptr);
    if (uri == nullptr) {
      fl_method_call_respond_error(call, "DIRECTORY", "Invalid filesystem path", nullptr, nullptr);
      return;
    }
    g_app_info_launch_default_for_uri_async(uri, nullptr, nullptr, folder_opened, g_object_ref(call));
  } else {
    fl_method_call_respond_not_implemented(call, nullptr);
  }
}
}  // namespace

Dukto2PlatformBridge* dukto2_platform_bridge_new(
    GtkApplication* application, GtkWindow* window, FlBinaryMessenger* messenger) {
  auto* bridge = new Dukto2PlatformBridge{application, window, nullptr, 0};
  g_object_add_weak_pointer(G_OBJECT(window), reinterpret_cast<gpointer*>(&bridge->window));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  bridge->channel = fl_method_channel_new(messenger, "dukto2/platform", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(bridge->channel, method_call, bridge, nullptr);
  return bridge;
}

void dukto2_platform_bridge_free(Dukto2PlatformBridge* bridge) {
  fl_method_channel_set_method_call_handler(bridge->channel, nullptr, nullptr, nullptr);
  g_clear_object(&bridge->channel);
  if (bridge->inhibit_cookie != 0) {
    gtk_application_uninhibit(bridge->application, bridge->inhibit_cookie);
  }
  if (bridge->window != nullptr) {
    g_object_remove_weak_pointer(G_OBJECT(bridge->window), reinterpret_cast<gpointer*>(&bridge->window));
  }
  delete bridge;
}
