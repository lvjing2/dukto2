package dev.dukto2.dukto2

import android.Manifest
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.Uri
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

import android.os.Handler
import android.os.Looper
import java.lang.ref.WeakReference
/** Runtime-owned platform resources; only UI operations require an attached Activity. */
class PlatformBridge(context: Context) : ContextWrapper(context.applicationContext) {
    private var owner = WeakReference<MainActivity>(null)
    val hasActivity get() = owner.get() != null
    private val ui get() = owner.get() ?: error("No visible Activity")
    private val window get() = owner.get()?.window
    fun attach(activity: MainActivity) { owner = WeakReference(activity) }
    fun detach(activity: MainActivity) {
        if (owner.get() !== activity) return
        owner.clear()
        folderResult?.error("CLOSED", "Activity detached", null); folderResult = null
        notificationPermissionResult?.error("CLOSED", "Activity detached", null); notificationPermissionResult = null
        exportResult?.error("CLOSED", "Activity detached", null); exportResult = null
    }
    private fun runOnUiThread(action: () -> Unit) { Handler(Looper.getMainLooper()).post(action) }
    private fun requestPermissions(permissions: Array<String>, code: Int) = ui.requestPermissions(permissions, code)
    private fun startActivityForResult(intent: Intent, code: Int) = ui.startActivityForResult(intent, code)
    override fun startActivity(intent: Intent) = ui.startActivity(intent)
    private var storage: ReceiveStorage? = null
    private var folderResult: MethodChannel.Result? = null
    private var notificationTitle = "Dukto2 transfer"
    private var notificationPermissionResult: MethodChannel.Result? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var bridge: MethodChannel? = null
    private var multicastLock: WifiManager.MulticastLock? = null
    private var exportResult: MethodChannel.Result? = null
    private var exportSource: File? = null

    fun initialize(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dukto2/platform")
        bridge = channel
        storage = ReceiveStorage(applicationContext)
        TransferService.onStopped = { reason -> runOnUiThread { channel.invokeMethod("transferStopped", reason) } }
        val connectivity = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) { runOnUiThread { channel.invokeMethod("networkChanged", null) } }
            override fun onLost(network: Network) { runOnUiThread { channel.invokeMethod("networkChanged", null) } }
        }.also { connectivity.registerDefaultNetworkCallback(it) }
        channel.setMethodCallHandler { call, result ->
                if (storage!!.handle(call, result)) return@setMethodCallHandler
                when (call.method) {
                    "configureLocalization" -> {
                        NativeLocalization.configure(this, call.arguments as? Map<*, *> ?: emptyMap<String, String>())
                        result.success(null)
                    }
                    "chooseReceiveFolder" -> {
                        if (folderResult != null) { result.error("BUSY", "Folder picker is open", null); return@setMethodCallHandler }
                        folderResult = result
                        try {
                            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                            }
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, FOLDER_REQUEST)
                        } catch (error: Exception) { folderResult = null; result.error("STORAGE", error.message, null) }
                    }
                    "backgroundReceiveStatus" -> result.success(BackgroundReceiveService.allowed(this))
                    "startBackgroundReceive" -> {
                        try {
                            check(DuktoRuntime.visible) { "Start background reception from the visible app" }
                            check(BackgroundReceiveService.allowed(this)) { "Notifications are disabled" }
                            val duration = (call.argument<Number>("milliseconds")?.toLong() ?: 1800000L).coerceIn(1000L, 1800000L)
                            val intent = Intent(this, BackgroundReceiveService::class.java).putExtra("duration", duration)
                            if (Build.VERSION.SDK_INT >= 26) startForegroundService(intent) else startService(intent)
                            result.success(null)
                        } catch (error: Exception) { result.error("BACKGROUND", error.message, null) }
                    }
                    "stopBackgroundReceive" -> { stopService(Intent(this, BackgroundReceiveService::class.java)); result.success(null) }
                    "showReceiveRequest" -> result.success(BackgroundReceiveService.showRequest(this, call.argument<String>("id") ?: ""))
                    "clearReceiveRequest" -> { BackgroundReceiveService.clearRequest(this, call.argument<String>("id")); result.success(null) }
                    "startTransfer" -> {
                        notificationTitle = call.argument<String>("title") ?: NativeLocalization.text(this, "transferTitle")
                        // Notification permission controls presentation, not FGS eligibility.
                        // Never hold the transfer handshake open while the user reads a prompt.
                        startTransferService(result)
                    }
                    "notificationStatus" -> result.success(notificationStatus())
                    "requestNotifications" -> {
                        if (notificationPermissionResult != null) { result.error("BUSY", "Permission request is open", null); return@setMethodCallHandler }
                        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                            notificationPermissionResult = result
                            getSharedPreferences("MainActivity", Context.MODE_PRIVATE).edit().putBoolean("notificationsAsked", true).apply()
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_REQUEST)
                        } else result.success(notificationStatus())
                    }
                    "openNotificationSettings" -> {
                        val intent = if (Build.VERSION.SDK_INT >= 26) Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        else Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
                        try { startActivity(intent); result.success(null) }
                        catch (error: Exception) { result.error("NOTIFICATIONS", error.message, null) }
                    }
                    "notifyComplete" -> {
                        CompletionNotifications.show(this, call.argument<String>("title") ?: NativeLocalization.text(this, "receiveTitle"), call.argument<String>("body") ?: NativeLocalization.text(this, "receiveBody"))
                        result.success(null)
                    }
                    "updateTransfer" -> {
                        TransferService.current?.update(call.argument<String>("title") ?: NativeLocalization.text(this, "transferTitle"),
                            call.argument<String>("text") ?: "", call.argument<Number>("progress")?.toInt() ?: -1)
                        result.success(null)
                    }
                    "stopTransfer" -> {
                        TransferService.stop(this)
                        result.success(null)
                    }
                    "getDeviceType" -> result.success(
                        if (resources.configuration.smallestScreenWidthDp >= 600) "tablet" else "phone"
                    )
                    "getDeviceName" -> {
                        val configured = try {
                            Settings.Global.getString(contentResolver, "device_name")
                        } catch (_: SecurityException) { null }
                        val model = Build.MODEL.orEmpty()
                        val brand = Build.MANUFACTURER.orEmpty()
                        val fallback = if (model.startsWith(brand, ignoreCase = true)) model else "$brand $model"
                        result.success(configured?.takeIf { it.isNotBlank() } ?: fallback.trim())
                    }
                    "startDiscovery" -> {
                        try {
                            val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                            if (multicastLock == null) {
                                multicastLock = wifi.createMulticastLock("dukto2-discovery").apply {
                                    setReferenceCounted(false)
                                }
                            }
                            if (multicastLock?.isHeld != true) multicastLock?.acquire()
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("DISCOVERY", error.message, null)
                        }
                    }
                    "stopDiscovery" -> {
                        releaseDiscovery()
                        result.success(null)
                    }
                    "keepAwake" -> {
                        if (call.arguments == true) {
                            window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    "exportFile" -> {
                        if (exportResult != null) {
                            result.error("BUSY", "Another export is in progress", null)
                            return@setMethodCallHandler
                        }
                        val path = call.argument<String>("path")
                        val source = path?.let { File(it).canonicalFile }
                        // The channel can only export files from this app's private data.
                        if (source == null || !source.isFile ||
                            !source.path.startsWith(File(applicationInfo.dataDir).canonicalPath + File.separator)) {
                            result.error("FILE", "Received file no longer exists", null)
                            return@setMethodCallHandler
                        }
                        exportResult = result
                        exportSource = source
                        try {
                            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "application/octet-stream"
                                putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: source.name)
                            }
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, EXPORT_REQUEST)
                        } catch (error: Exception) {
                            exportResult = null
                            exportSource = null
                            result.error("EXPORT", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Activity result bridge used by FlutterActivity")
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == FOLDER_REQUEST) {
            val result = folderResult ?: return
            folderResult = null
            val uri = data?.data
            if (resultCode != Activity.RESULT_OK || uri == null) result.success(null)
            else storage!!.setFolder(uri, data.flags, result)
            return
        }
        if (requestCode != EXPORT_REQUEST) return
        val result = exportResult ?: return
        val source = exportSource
        exportResult = null
        exportSource = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || source == null) {
            result.success(false)
            return
        }
        Thread {
            try {
                contentResolver.openOutputStream(uri, "wt").use { output ->
                    requireNotNull(output) { "Cannot write to selected location" }
                    source.inputStream().use { input -> input.copyTo(output, 1024 * 1024) }
                }
                runOnUiThread { result.success(true) }
            } catch (error: Exception) {
                runOnUiThread { result.error("EXPORT", error.message, null) }
            }
        }.start()
    }

    private fun startTransferService(result: MethodChannel.Result) {
        try {
            val intent = Intent(this, TransferService::class.java).putExtra("title", notificationTitle)
            if (Build.VERSION.SDK_INT >= 26) startForegroundService(intent) else startService(intent)
            result.success(null)
        } catch (error: Exception) { result.error("BACKGROUND", error.message, null) }
    }

    private fun notificationStatus(): String = CompletionNotifications.status(this,
        getSharedPreferences("MainActivity", Context.MODE_PRIVATE).getBoolean("notificationsAsked", false))

    fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == NOTIFICATION_REQUEST) {
            notificationPermissionResult?.success(notificationStatus())
            notificationPermissionResult = null
        }
    }


    private fun releaseDiscovery() {
        if (multicastLock?.isHeld == true) multicastLock?.release()
        multicastLock = null
    }

    fun close() {
        releaseDiscovery()
        networkCallback?.let { (getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager).unregisterNetworkCallback(it) }
        TransferService.onStopped = null
        TransferService.stop(this)
        storage?.shutdown()
        folderResult?.error("CLOSED", "Activity closed", null)
        notificationPermissionResult?.error("CLOSED", "Activity closed", null)
        notificationPermissionResult = null
        exportResult?.error("CLOSED", "Activity closed", null)
        exportResult = null
    }

    fun event(method: String, value: Any? = null) { bridge?.invokeMethod(method, value) }
    fun shutdownRuntime(done: () -> Unit) {
        val channel = bridge
        if (channel == null) { done(); return }
        channel.invokeMethod("runtimeStopping", null, object : MethodChannel.Result {
            override fun success(result: Any?) = done()
            override fun error(code: String, message: String?, details: Any?) = done()
            override fun notImplemented() = done()
        })
    }
    companion object {
        private const val EXPORT_REQUEST = 45879
        private const val FOLDER_REQUEST = 45880
        private const val NOTIFICATION_REQUEST = 45881
    }
}
