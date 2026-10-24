package com.sirine.for_anis

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Intent
import android.os.SystemClock
import android.telecom.TelecomManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * The enforcement brain. While a session is active it:
 *  - sends Anis back whenever a blocked app comes to the foreground, showing
 *    the loving [BlockActivity];
 *  - bounces out of screens he could use to escape (this app's App Info,
 *    Device Admin, Accessibility and Date & Time settings, and uninstall
 *    dialogs for this app).
 *
 * The dialer, the default launcher and this app itself are never blocked.
 */
class FocusAccessibilityService : AccessibilityService() {

    private var lastBlockedPackage: String? = null
    private var lastActionAt: Long = 0

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED &&
            event.eventType != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
        ) return

        if (!SessionStore.isActive(this)) {
            lastBlockedPackage = null
            return
        }

        val pkg = event.packageName?.toString() ?: return
        val className = event.className?.toString() ?: ""

        // Never act on our own screens (home UI, block screen).
        if (pkg == packageName) return

        // Safety: never block the launcher or the dialer.
        if (pkg == defaultLauncher() || pkg == defaultDialer() || isSafePackage(pkg)) {
            return
        }

        if (SessionStore.isBlocked(this, pkg)) {
            blockNow(pkg)
            return
        }

        guardEscape(pkg, className, event)
    }

    override fun onInterrupt() {}

    // --- Blocking ---

    private fun blockNow(pkg: String) {
        val now = SystemClock.elapsedRealtime()
        // Debounce repeated events for the same app.
        if (pkg == lastBlockedPackage && now - lastActionAt < 800) return
        lastBlockedPackage = pkg
        lastActionAt = now

        val intent = Intent(this, BlockActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_NO_ANIMATION
            )
            putExtra(BlockActivity.EXTRA_PACKAGE, pkg)
        }
        startActivity(intent)
    }

    // --- Anti-escape ---

    private fun guardEscape(pkg: String, className: String, event: AccessibilityEvent) {
        val lowerClass = className.lowercase()
        val isSettings = pkg == "com.android.settings" ||
            pkg == "com.android.settings.intelligence" ||
            pkg.contains("settings")
        val isInstaller = pkg.contains("packageinstaller") || pkg.contains("packageinstall")

        if (isInstaller) {
            // An uninstall flow — if it mentions our app, bounce out.
            if (windowMentionsUs(event)) bounceHome()
            return
        }

        if (isSettings) {
            val guardedClass = lowerClass.contains("deviceadmin") ||
                lowerClass.contains("accessibilit") ||
                lowerClass.contains("datetime") ||
                lowerClass.contains("date_time") ||
                lowerClass.contains("installedappdetails") ||
                lowerClass.contains("appinfodashboard") ||
                lowerClass.contains("applicationdetails")
            val text = windowText(event).lowercase()
            val guardedText = (text.contains("device admin") ||
                text.contains("accessibility") ||
                text.contains("date & time") ||
                text.contains("uninstall") ||
                text.contains("app info") ||
                text.contains("force stop")) &&
                (text.contains("for anis") || guardedClass)
            if (guardedClass || guardedText) bounceHome()
        }
    }

    private fun bounceHome() {
        val now = SystemClock.elapsedRealtime()
        if (now - lastActionAt < 500) return
        lastActionAt = now
        performGlobalAction(GLOBAL_ACTION_BACK)
        val home = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(home)
    }

    // --- Helpers ---

    private fun isSafePackage(pkg: String): Boolean {
        return pkg == "com.android.dialer" ||
            pkg == "com.google.android.dialer" ||
            pkg == "com.android.phone" ||
            pkg == "com.android.server.telecom" ||
            pkg == "com.android.emergency"
    }

    private fun defaultLauncher(): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            packageManager.resolveActivity(intent, 0)?.activityInfo?.packageName
        } catch (_: Throwable) {
            null
        }
    }

    private fun defaultDialer(): String? {
        return try {
            val tm = getSystemService(TelecomManager::class.java)
            tm?.defaultDialerPackage
        } catch (_: Throwable) {
            null
        }
    }

    private fun windowMentionsUs(event: AccessibilityEvent): Boolean {
        val text = windowText(event).lowercase()
        return text.contains("for anis") || text.contains(packageName)
    }

    private fun windowText(event: AccessibilityEvent): String {
        val node = rootInActiveWindow ?: event.source ?: return ""
        val sb = StringBuilder()
        collectText(node, sb, 0)
        return sb.toString()
    }

    private fun collectText(node: AccessibilityNodeInfo?, sb: StringBuilder, depth: Int) {
        if (node == null || depth > 12) return
        node.text?.let { sb.append(it).append(' ') }
        node.contentDescription?.let { sb.append(it).append(' ') }
        for (i in 0 until node.childCount) {
            collectText(node.getChild(i), sb, depth + 1)
        }
    }

    companion object {
        fun componentName(ctx: android.content.Context): ComponentName =
            ComponentName(ctx, FocusAccessibilityService::class.java)
    }
}
