package com.sirine.for_anis

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

/**
 * Keeps a started session alive with a persistent, styled notification and
 * ticks the cheat-proof timer once a second. When the timer reaches zero it
 * marks the session complete and stops itself.
 */
class FocusForegroundService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var ticker: Runnable

    override fun onCreate() {
        super.onCreate()
        createChannel()
        ticker = Runnable { tick() }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        SessionStore.ensureAnchored(this)
        if (!SessionStore.isActive(this)) {
            stopSelf()
            return START_NOT_STICKY
        }
        startForeground(NOTIFICATION_ID, buildNotification(SessionStore.remainingMs(this)))
        scheduleTick()
        return START_STICKY
    }

    private fun scheduleTick() {
        handler.removeCallbacks(ticker)
        handler.postDelayed(ticker, 1000)
    }

    private fun tick() {
        if (!SessionStore.isActive(this)) {
            stopNow()
            return
        }
        val remaining = SessionStore.remainingMs(this)
        if (remaining <= 0) {
            onComplete()
            return
        }
        SessionStore.checkpoint(this)
        notificationManager().notify(NOTIFICATION_ID, buildNotification(remaining))
        FocusEventBridge.emit(this)
        scheduleTick()
    }

    private fun onComplete() {
        SessionStore.complete(this)
        FocusEventBridge.emit(this)
        notificationManager().notify(DONE_NOTIFICATION_ID, buildDoneNotification())
        stopNow()
    }

    private fun stopNow() {
        handler.removeCallbacks(ticker)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        handler.removeCallbacks(ticker)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // --- Notifications ---

    private fun notificationManager() =
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun createChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Focus session",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Shows the time left in your focus session."
            setShowBadge(false)
        }
        notificationManager().createNotificationChannel(channel)
    }

    private fun contentIntent(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun buildNotification(remainingMs: Long): Notification {
        val left = formatClock(remainingMs)
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_focus)
            .setContentTitle("Focusing 💗")
            .setContentText("$left left — you've got this, Anis")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(contentIntent())
            .build()
    }

    private fun buildDoneNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_focus)
            .setContentTitle("Session complete 💗")
            .setContentText("You did it, Anis. Sirine is proud of you.")
            .setAutoCancel(true)
            .setContentIntent(contentIntent())
            .build()
    }

    private fun formatClock(ms: Long): String {
        val totalSeconds = ms / 1000
        val h = totalSeconds / 3600
        val m = (totalSeconds % 3600) / 60
        val s = totalSeconds % 60
        return "%02d:%02d:%02d".format(h, m, s)
    }

    companion object {
        private const val CHANNEL_ID = "focus_session"
        private const val NOTIFICATION_ID = 1001
        private const val DONE_NOTIFICATION_ID = 1002

        fun start(ctx: Context) {
            val intent = Intent(ctx, FocusForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ctx.startForegroundService(intent)
            } else {
                ctx.startService(intent)
            }
        }
    }
}
