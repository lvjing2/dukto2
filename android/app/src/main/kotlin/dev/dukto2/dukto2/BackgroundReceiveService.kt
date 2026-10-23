package dev.dukto2.dukto2

import android.Manifest
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.*

/** Explicitly enabled receive window. No idle wake locks or automatic restart. */
class BackgroundReceiveService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val expiry = Runnable { DuktoRuntime.bridge?.event("backgroundReceiveExpired") }
    override fun onCreate() { super.onCreate(); active = true; channels(this) }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == STOP) {
            DuktoRuntime.bridge?.event("backgroundReceiveExpired")
            return START_NOT_STICKY
        }
        val duration = intent?.getLongExtra("duration", 1800000L) ?: 1800000L
        val open = PendingIntent.getActivity(this, 901, Intent(this, MainActivity::class.java), FLAGS)
        val stop = PendingIntent.getService(this, 903, Intent(this, BackgroundReceiveService::class.java).setAction(STOP), FLAGS)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, WAITING) else Notification.Builder(this)
        val notification = builder.setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(NativeLocalization.text(this, "backgroundTitle"))
            .setContentText(NativeLocalization.text(this, "backgroundBody"))
            .setOngoing(true).setOnlyAlertOnce(true).setContentIntent(open)
            .setWhen(System.currentTimeMillis() + duration).setUsesChronometer(true).setChronometerCountDown(true)
            .addAction(Notification.Action.Builder(null, NativeLocalization.text(this, "backgroundStop"), stop).build()).build()
        if (Build.VERSION.SDK_INT >= 29) startForeground(ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE)
        else startForeground(ID, notification)
        handler.removeCallbacks(expiry)
        handler.postDelayed(expiry, duration)
        return START_NOT_STICKY
    }
    override fun onTaskRemoved(intent: Intent?) { DuktoRuntime.stop(); stopSelf() }
    override fun onDestroy() {
        active = false
        handler.removeCallbacks(expiry)
        clearRequest(this, null)
        DuktoRuntime.bridge?.event("backgroundReceiveExpired")
        DuktoRuntime.releaseIfUnused()
        super.onDestroy()
    }
    override fun onBind(intent: Intent?): IBinder? = null
    companion object {
        var active = false
            private set
        private const val WAITING = "dukto2-background-waiting"
        private const val REQUESTS = "dukto2-receive-requests"
        private const val ID = 45881
        private const val REQUEST_ID = 45882
        private const val STOP = "dev.dukto2.background.STOP"
        private const val FLAGS = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        private var request: String? = null
        private var lastAlert = 0L
        private fun channels(context: Context) {
            if (Build.VERSION.SDK_INT < 26) return
            context.getSystemService(NotificationManager::class.java).apply {
                createNotificationChannel(NotificationChannel(WAITING, NativeLocalization.text(context, "backgroundTitle"), NotificationManager.IMPORTANCE_LOW))
                createNotificationChannel(NotificationChannel(REQUESTS, NativeLocalization.text(context, "requestChannel"), NotificationManager.IMPORTANCE_DEFAULT))
            }
        }
        fun allowed(context: Context): Boolean {
            if (Build.VERSION.SDK_INT >= 33 && context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return false
            val manager = context.getSystemService(NotificationManager::class.java)
            if (!manager.areNotificationsEnabled()) return false
            if (Build.VERSION.SDK_INT >= 26 && listOf(WAITING, REQUESTS).any { manager.getNotificationChannel(it)?.importance == NotificationManager.IMPORTANCE_NONE }) return false
            return true
        }
        fun showRequest(context: Context, id: String): Boolean {
            if (!id.matches(Regex("[a-f0-9]{16}")) || !allowed(context)) return false
            channels(context)
            val open = PendingIntent.getActivity(context, 904, Intent(context, MainActivity::class.java)
                .putExtra("dukto2.request", id).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), FLAGS)
            val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, REQUESTS) else Notification.Builder(context)
            val now = SystemClock.elapsedRealtime()
            val quiet = now - lastAlert < 10000
            val notification = builder.setSmallIcon(android.R.drawable.stat_sys_download)
                .setContentTitle(NativeLocalization.text(context, "requestTitle"))
                .setContentText(NativeLocalization.text(context, "requestBody"))
                .setContentIntent(open).setAutoCancel(true).setOnlyAlertOnce(true)
                .setVisibility(Notification.VISIBILITY_PRIVATE).setLocalOnly(true)
            if (quiet) {
                if (Build.VERSION.SDK_INT >= 26) notification.setGroup("dukto2-quiet-requests").setGroupAlertBehavior(Notification.GROUP_ALERT_SUMMARY)
                else notification.setDefaults(0).setSound(null).setVibrate(null)
            }
            return try {
                context.getSystemService(NotificationManager::class.java).notify(REQUEST_ID, notification.build())
                request = id; lastAlert = now; true
            } catch (_: SecurityException) { false }
        }
        fun clearRequest(context: Context, id: String?) {
            if (id != null && id != request) return
            request = null
            context.getSystemService(NotificationManager::class.java).cancel(REQUEST_ID)
        }
    }
}
