package dev.dukto2.dukto2

import android.app.Activity
import android.app.Instrumentation
import android.content.Intent
import android.content.pm.PackageManager
import android.Manifest
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.widget.Button

/** Device smoke test, deliberately restricted to a disposable, separate package. */
class PrivacyDeviceInstrumentation : Instrumentation() {
    override fun onCreate(arguments: Bundle?) {
        super.onCreate(arguments)
        start()
    }

    override fun onStart() {
        val output = Bundle()
        try {
            check(targetContext.packageName == "dev.dukto2.privacyvalidation") {
                "Device test is allowed only on the isolated privacy package"
            }
            check(!PrivacyConsent.accepted(targetContext)) { "Use a fresh validation install" }
            fun progress(message: String) = sendStatus(0, Bundle().apply {
                putString("stream", "$message\n")
            })
            fun launch(): Activity {
                val monitor = addMonitor(PrivacyActivity::class.java.name, null, false)
                // A rejection removes the task. Re-enter through the system
                // launcher rather than relying on background activity launch
                // privileges of the now-background test process.
                ParcelFileDescriptor.AutoCloseInputStream(uiAutomation.executeShellCommand(
                    "am start -W -n ${targetContext.packageName}/${PrivacyActivity::class.java.name}"
                )).use { it.readBytes() }
                val activity = waitForMonitorWithTimeout(monitor, 10000)
                removeMonitor(monitor)
                check(activity != null) { "Privacy activity did not launch" }
                runOnMainSync { }
                return activity
            }
            fun runtimeAbsent() {
                val field = DuktoRuntime::class.java.getDeclaredField("retained").apply { isAccessible = true }
                check(field.get(null) == null) { "Runtime started before agreement" }
                check(targetContext.checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_DENIED)
            }
            progress("Checking first launch")
            val first = launch()
            runtimeAbsent()
            progress("Checking rejection")
            runOnMainSync { first.window.decorView.findViewWithTag<Button>("privacy-decline").performClick() }
            runOnMainSync { }
            check(!PrivacyConsent.accepted(targetContext))
            progress("Checking relaunch")
            val second = launch()
            runtimeAbsent()
            check(second.window.decorView.findViewWithTag<Button>("privacy-accept") != null)
            val main = addMonitor(MainActivity::class.java.name, null, false)
            progress("Checking explicit acceptance and runtime startup")
            runOnMainSync { second.window.decorView.findViewWithTag<Button>("privacy-accept").performClick() }
            val launched = waitForMonitorWithTimeout(main, 20000)
            check(launched != null) { "Main activity did not start after agreement" }
            runOnMainSync { }
            check(PrivacyConsent.accepted(targetContext))
            check(DuktoRuntime.bridge != null) { "Runtime not attached after agreement" }
            removeMonitor(main)
            output.putString("stream", "PASS: real-device first launch, no pre-consent runtime/camera permission, decline, relaunch, durable acceptance and runtime startup.\n")
            finish(Activity.RESULT_OK, output)
        } catch (error: Throwable) {
            output.putString("stream", "FAIL: ${error.javaClass.simpleName}: ${error.message}\n")
            finish(Activity.RESULT_CANCELED, output)
        }
    }
}
