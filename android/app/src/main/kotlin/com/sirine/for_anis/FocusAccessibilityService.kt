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

    private var cachedLaunchers: Set<String>? = null
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())
    private val contentCheck = Runnable {
        if (SessionStore.isActive(this) && isEscapeScreen()) bounceHome()
    }

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
        if (launcherPackages().contains(pkg) || pkg == defaultDialer() || isSafePackage(pkg)) {
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
            if (windowMentionsUs(event)) bounceHome() else scheduleContentCheck()
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
            if (guardedClass) {
                bounceHome()
                return
            }
            // Modern Settings is Compose-based: the class name is generic and
            // the content arrives after the window event, so re-scan the live
            // window shortly afterwards.
            scheduleContentCheck()
        }
    }

    /** Re-reads the foreground window a moment later and bounces if it's an escape screen. */
    private fun scheduleContentCheck() {
        handler.removeCallbacks(contentCheck)
        handler.postDelayed(contentCheck, 350)
        handler.postDelayed(contentCheck, 900)
    }

    private fun isEscapeScreen(): Boolean {
        val text = currentWindowText().lowercase()
        if (text.isEmpty()) return false
        val mentionsUs = text.contains("for anis") || text.contains(packageName)
        // This app's App Info / uninstall / device-admin detail screen.
        if (mentionsUs && (text.contains("uninstall") ||
                text.contains("force stop") ||
                text.contains("deactivate") ||
                text.contains("turn off this device admin"))
        ) return true
        // The device admin list and the accessibility list (which names us).
        if (text.contains("device admin apps")) return true
        if (mentionsUs && text.contains("installed apps") &&
            text.contains("accessibility")
        ) return true
        // Date & time, which could be used to fiddle with the clock.
        if (text.contains("set time automatically") ||
            text.contains("set date and time") ||
            text.contains("date & time")
        ) return true
        return false
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

    /**
     * Real home-screen packages.
     *
     * Note: `com.android.settings` also declares a HOME activity (FallbackHome,
     * used during boot), so resolving the home intent naively would whitelist
     * the whole Settings app and disable the anti-escape guard. The system
     * resolver ("android") is excluded for the same reason.
     */
    private fun launcherPackages(): Set<String> {
        cachedLaunchers?.let { return it }
        val found = try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            packageManager.queryIntentActivities(intent, 0)
                .map { it.activityInfo.packageName }
                .filter { it != "com.android.settings" && it != "android" }
                .toSet()
        } catch (_: Throwable) {
            emptySet()
        }
        cachedLaunchers = found
        return found
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
        val text = (currentWindowText() + ' ' + windowText(event)).lowercase()
        return text.contains("for anis") || text.contains(packageName)
    }

    private fun windowText(event: AccessibilityEvent): String {
        val node = event.source ?: return ""
        val sb = StringBuilder()
        collectText(node, sb, 0)
        return sb.toString()
    }

    /**
     * Text of every node in the active window. Settings screens are Compose
     * based and nest deeply, so the depth limit is generous.
     */
    private fun currentWindowText(): String {
        val sb = StringBuilder()
        try {
            rootInActiveWindow?.let { collectText(it, sb, 0) }
            for (w in windows) {
                w.root?.let { collectText(it, sb, 0) }
                if (sb.length > 8000) break
            }
        } catch (_: Throwable) {
            // Window went away mid-scan; whatever we collected is fine.
        }
        return sb.toString()
    }

    private fun collectText(node: AccessibilityNodeInfo?, sb: StringBuilder, depth: Int) {
        if (node == null || depth > 40 || sb.length > 8000) return
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
