package com.sirine.for_anis

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Restores a running session after a reboot. [SessionStore.ensureAnchored]
 * re-bases the countdown so the downtime is never credited, then the
 * foreground service picks the timer back up.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_LOCKED_BOOT_COMPLETED
        ) {
            SessionStore.ensureAnchored(context)
            if (SessionStore.isActive(context)) {
                FocusForegroundService.start(context)
            }
        }
    }
}
