package dev.dukto2.dukto2

import android.content.Context

/** Separate from Flutter preferences: checked before an engine or SDK is created. */
object PrivacyConsent {
    const val POLICY_VERSION = "2026-11-18"
    const val POLICY_URL = "https://qtlink.cn/dukto2/privacy.html"
    private const val STORE = "privacy-consent"

    fun accepted(context: Context): Boolean =
        context.getSharedPreferences(STORE, Context.MODE_PRIVATE)
            .getString("accepted-policy", null) == POLICY_VERSION

    // Do not enter the runtime unless the acceptance has been durably saved.
    fun accept(context: Context): Boolean =
        context.getSharedPreferences(STORE, Context.MODE_PRIVATE).edit()
            .putString("accepted-policy", POLICY_VERSION).commit()
}
