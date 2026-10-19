package dev.dukto2.dukto2

import android.content.Context

/** Presentation-only cache for a service created before the Dart bridge is ready. */
object NativeLocalization {
    private val defaults = mapOf(
        "transferTitle" to "Dukto2 transfer", "preparing" to "Preparing transfer…",
        "cancel" to "Cancel", "transferChannel" to "File transfers",
        "completionChannel" to "Transfer completion notifications",
        "receiveTitle" to "Receiving complete", "receiveBody" to "File received and verified",
        "sendTitle" to "Sending complete", "sendBody" to "File sent and verified")

    fun text(context: Context, key: String): String =
        context.getSharedPreferences("localization", Context.MODE_PRIVATE).getString(key, null)
            ?: defaults[key].orEmpty()

    fun configure(context: Context, values: Map<*, *>) {
        val edit = context.getSharedPreferences("localization", Context.MODE_PRIVATE).edit()
        for (key in defaults.keys) {
            val value = values[key] as? String ?: continue
            if (value.isNotBlank() && value.length <= 512) edit.putString(key, value)
        }
        edit.apply()
        TransferService.current?.refreshLocalization()
        CompletionNotifications.updateChannel(context)
    }
}
