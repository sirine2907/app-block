package com.sirine.for_anis

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

/**
 * Being an active device admin makes For Anis harder to uninstall mid-session.
 * If Anis tries to turn it off, [onDisableRequested] returns a gentle warning.
 */
class FocusDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        return if (SessionStore.isActive(context)) {
            "A focus session is still running, Anis. Turning this off won't end " +
                "it any sooner — let's finish strong. 💗 — Sirine"
        } else {
            "Turning this off means For Anis can be removed. You can always come " +
                "back when you're ready to focus again. 💗"
        }
    }
}
