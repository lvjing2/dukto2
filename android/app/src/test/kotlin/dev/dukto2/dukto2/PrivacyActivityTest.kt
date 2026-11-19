package dev.dukto2.dukto2

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.widget.Button
import android.view.View
import com.google.mlkit.common.sdkinternal.MlKitContext
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class PrivacyActivityTest {
    private val context get() = RuntimeEnvironment.getApplication()

    @Before fun freshInstall() {
        context.getSharedPreferences("privacy-consent", Context.MODE_PRIVATE).edit().clear().commit()
    }

    private fun assertRuntimeNotStarted() {
        val field = DuktoRuntime::class.java.getDeclaredField("retained")
        field.isAccessible = true
        assertNull(field.get(null))
        try {
            MlKitContext.getInstance()
            fail("ML Kit must not initialize before consent")
        } catch (_: IllegalStateException) { }
    }

    @Test fun firstLaunchDoesNotStartSdkRuntimeOrRequestPermissions() {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        assertEquals(PrivacyActivity::class.java.name, launch!!.component!!.className)
        val controller = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        val activity = controller.get()
        assertFalse(PrivacyConsent.accepted(activity))
        assertRuntimeNotStarted()
        assertNull(shadowOf(activity).nextStartedActivity)
        assertEquals(PackageManager.PERMISSION_DENIED, activity.checkSelfPermission(Manifest.permission.CAMERA))
        assertNotNull(activity.window.decorView.findViewWithTag<View>("privacy-accept"))
        controller.pause().stop().destroy()
    }

    @Test fun noticeOverlaysHomeAndKeepsActionsReachableOnShortScreens() {
        val controller = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        val activity = controller.get()
        val content = activity.findViewById<android.widget.FrameLayout>(android.R.id.content)
        val home = content.findViewWithTag<View>("privacy-home-preview")
        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS, home.importantForAccessibility)
        for ((width, height) in listOf(375 to 720, 720 to 320, 800 to 1024)) {
            repeat(2) {
                content.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
                content.layout(0, 0, width, height)
            }
            val card = content.findViewWithTag<View>("privacy-dialog")
            assertTrue(card.top >= 0 && card.bottom <= height)
            for (tag in listOf("privacy-read-policy", "privacy-accept", "privacy-decline")) {
                val button = content.findViewWithTag<Button>(tag)
                assertTrue("$tag must fit in the dialog", button.top >= 0 && button.bottom <= card.height)
                assertTrue(button.height > 0)
            }
            assertTrue(content.findViewWithTag<View>("privacy-summary-scroll").height > 0)
        }
        assertRuntimeNotStarted()
        controller.pause().stop().destroy()
    }

    @Test fun readingPolicyDoesNotAcceptOrStartRuntime() {
        val controller = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        val activity = controller.get()
        activity.window.decorView.findViewWithTag<Button>("privacy-read-policy").performClick()
        assertFalse(PrivacyConsent.accepted(activity))
        assertRuntimeNotStarted()
        // An external policy reader, never the scanner or Flutter activity.
        val next = shadowOf(activity).nextStartedActivity
        if (next != null) assertEquals(PrivacyConsent.POLICY_URL, next.dataString)
        controller.pause().stop().destroy()
    }

    @Test fun declineDoesNotPersistConsentAndNextLaunchStillAsks() {
        val first = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        first.get().window.decorView.findViewWithTag<Button>("privacy-decline").performClick()
        assertTrue(first.get().isFinishing)
        assertFalse(PrivacyConsent.accepted(context))
        assertRuntimeNotStarted()
        first.pause().stop().destroy()
        val second = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        assertNotNull(second.get().window.decorView.findViewWithTag<View>("privacy-accept"))
        second.pause().stop().destroy()
    }

    @Test fun acceptPersistsBeforeOpeningAppAndIsRemembered() {
        val first = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        val activity = first.get()
        activity.window.decorView.findViewWithTag<Button>("privacy-accept").performClick()
        assertTrue(PrivacyConsent.accepted(context))
        assertEquals(MainActivity::class.java.name, shadowOf(activity).nextStartedActivity.component!!.className)
        assertTrue(activity.isFinishing)
        first.pause().stop().destroy()
        val second = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        assertEquals(MainActivity::class.java.name, shadowOf(second.get()).nextStartedActivity.component!!.className)
        second.pause().stop().destroy()
    }

    @Test fun anOlderPolicyAcceptanceDoesNotBypassTheNewNotice() {
        context.getSharedPreferences("privacy-consent", Context.MODE_PRIVATE).edit()
            .putString("accepted-policy", "older-policy").commit()
        val controller = Robolectric.buildActivity(PrivacyActivity::class.java).setup()
        assertFalse(PrivacyConsent.accepted(context))
        assertNotNull(controller.get().window.decorView.findViewWithTag<View>("privacy-accept"))
        assertRuntimeNotStarted()
        controller.pause().stop().destroy()
    }
}
