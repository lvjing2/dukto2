package dev.dukto2.dukto2

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var multicastLock: WifiManager.MulticastLock? = null
    private var exportResult: MethodChannel.Result? = null
    private var exportSource: File? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dukto2/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
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
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
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
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
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

    private fun releaseDiscovery() {
        if (multicastLock?.isHeld == true) multicastLock?.release()
        multicastLock = null
    }

    override fun onDestroy() {
        releaseDiscovery()
        exportResult?.error("CLOSED", "Activity closed", null)
        exportResult = null
        super.onDestroy()
    }

    companion object { private const val EXPORT_REQUEST = 45879 }
}
