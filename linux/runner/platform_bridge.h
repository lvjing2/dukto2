#ifndef DUKTO2_PLATFORM_BRIDGE_H_
#define DUKTO2_PLATFORM_BRIDGE_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

struct Dukto2PlatformBridge;
Dukto2PlatformBridge* dukto2_platform_bridge_new(
    GtkApplication* application, GtkWindow* window, FlBinaryMessenger* messenger);
void dukto2_platform_bridge_free(Dukto2PlatformBridge* bridge);

#endif
