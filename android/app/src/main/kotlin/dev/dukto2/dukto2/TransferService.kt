package dev.dukto2.dukto2

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/** Protects an explicitly started transfer while the activity is backgrounded.
 * It never starts at boot or restarts a killed process. */
class TransferService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null
    private var title = "dukto2 正在传输"
    private var text = "正在准备传输…"
    private var progress = -1
    private var stopping = false

    override fun onCreate() {
        super.onCreate()
        current = this
        if (Build.VERSION.SDK_INT >= 26) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(CHANNEL, "文件传输", NotificationManager.IMPORTANCE_LOW))
        }
        if (Build.VERSION.SDK_INT >= 29) startForeground(ID, notification(), ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        else startForeground(ID, notification())
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "dukto2:transfer").apply {
            setReferenceCounted(false); acquire(6 * 60 * 60 * 1000L)
        }
        try {
            val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            @Suppress("DEPRECATION")
            val lock = wifi.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "dukto2-transfer")
            wifiLock = lock.apply { setReferenceCounted(false); acquire() }
        } catch (_: Exception) { /* The transport still reports network failure. */ }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == CANCEL) {
            onStopped?.invoke("已从通知取消传输")
            finish()
        } else {
            title = intent?.getStringExtra("title") ?: title
            text = intent?.getStringExtra("text") ?: text
            update(title, text, progress)
        }
        return START_NOT_STICKY
    }

    fun update(newTitle: String, newText: String, newProgress: Int) {
        if (stopping) return
        title = newTitle; text = newText; progress = newProgress
        getSystemService(NotificationManager::class.java).notify(ID, notification())
    }

    private fun notification(): Notification {
        val open = PendingIntent.getActivity(this, 0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val cancel = PendingIntent.getService(this, 1,
            Intent(this, TransferService::class.java).setAction(CANCEL),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, CHANNEL) else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder.setSmallIcon(android.R.drawable.stat_sys_upload)
            .setContentTitle(title).setContentText(text).setContentIntent(open)
            .setOngoing(true).setOnlyAlertOnce(true).setCategory(Notification.CATEGORY_PROGRESS)
            .setProgress(100, progress.coerceAtLeast(0), progress < 0)
            .addAction(Notification.Action.Builder(null, "取消", cancel).build()).build()
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        onStopped?.invoke("Android 后台传输时间已用尽，请返回应用重新发送")
        finish()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        onStopped?.invoke("应用已退出，传输已停止")
        finish()
    }

    private fun finish() {
        stopping = true
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        current = null
        if (wakeLock?.isHeld == true) wakeLock?.release()
        if (wifiLock?.isHeld == true) wifiLock?.release()
        if (!stopping) onStopped?.invoke("后台传输服务已停止")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        private const val CHANNEL = "dukto2-transfers"
        private const val ID = 45879
        private const val CANCEL = "dev.dukto2.dukto2.CANCEL"
        var current: TransferService? = null
            private set
        var onStopped: ((String) -> Unit)? = null
        fun stop(context: Context) {
            current?.stopping = true
            context.stopService(Intent(context, TransferService::class.java))
        }
    }
}
