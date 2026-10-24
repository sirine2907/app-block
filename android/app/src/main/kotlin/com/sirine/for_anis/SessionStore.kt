package com.sirine.for_anis

import android.content.Context
import android.os.SystemClock
import android.provider.Settings

/**
 * The single source of truth for a focus session, backed by SharedPreferences.
 *
 * The timer is cheat-proof:
 *  - Within one boot it counts down [SystemClock.elapsedRealtime], a monotonic
 *    clock that keeps running during deep sleep and is immune to wall-clock
 *    changes.
 *  - Across a reboot (detected via [Settings.Global.BOOT_COUNT] and by
 *    elapsedRealtime jumping backwards) it re-anchors to the remaining time
 *    captured at the last checkpoint. Downtime is never credited, so rebooting
 *    can only lengthen a session, never shorten it.
 */
object SessionStore {

    private const val PREFS = "for_anis_session"
    private const val NOTES_PREFS = "for_anis_notes"

    private const val KEY_ACTIVE = "active"
    private const val KEY_TOTAL = "total_ms"
    private const val KEY_END_ELAPSED = "end_elapsed"
    private const val KEY_BOOT_COUNT = "boot_count"
    private const val KEY_CP_ELAPSED = "cp_elapsed"
    private const val KEY_CP_REMAINING = "cp_remaining"
    private const val KEY_PACKAGES = "packages"
    private const val KEY_PENDING = "pending"
    private const val KEY_PENDING_DURATION = "pending_duration"

    private fun prefs(ctx: Context) =
        ctx.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun bootCount(ctx: Context): Int {
        return try {
            Settings.Global.getInt(ctx.contentResolver, Settings.Global.BOOT_COUNT, 0)
        } catch (_: Throwable) {
            0
        }
    }

    /** Starts a session for [durationMs] blocking [packages]. */
    fun start(ctx: Context, durationMs: Long, packages: List<String>) {
        val now = SystemClock.elapsedRealtime()
        prefs(ctx).edit()
            .putBoolean(KEY_ACTIVE, true)
            .putLong(KEY_TOTAL, durationMs)
            .putLong(KEY_END_ELAPSED, now + durationMs)
            .putInt(KEY_BOOT_COUNT, bootCount(ctx))
            .putLong(KEY_CP_ELAPSED, now)
            .putLong(KEY_CP_REMAINING, durationMs)
            .putStringSet(KEY_PACKAGES, packages.toSet())
            .putBoolean(KEY_PENDING, false)
            .putLong(KEY_PENDING_DURATION, 0)
            .apply()
    }

    fun isActive(ctx: Context): Boolean = prefs(ctx).getBoolean(KEY_ACTIVE, false)

    fun isPending(ctx: Context): Boolean = prefs(ctx).getBoolean(KEY_PENDING, false)

    fun totalMs(ctx: Context): Long = prefs(ctx).getLong(KEY_TOTAL, 0)

    fun pendingDurationMs(ctx: Context): Long =
        prefs(ctx).getLong(KEY_PENDING_DURATION, 0)

    fun blockedPackages(ctx: Context): Set<String> =
        prefs(ctx).getStringSet(KEY_PACKAGES, emptySet()) ?: emptySet()

    fun isBlocked(ctx: Context, pkg: String): Boolean =
        isActive(ctx) && blockedPackages(ctx).contains(pkg)

    /**
     * Re-anchors the countdown if a reboot was detected. Safe to call often.
     */
    fun ensureAnchored(ctx: Context) {
        val p = prefs(ctx)
        if (!p.getBoolean(KEY_ACTIVE, false)) return
        val now = SystemClock.elapsedRealtime()
        val storedBoot = p.getInt(KEY_BOOT_COUNT, 0)
        val currentBoot = bootCount(ctx)
        val cpElapsed = p.getLong(KEY_CP_ELAPSED, now)
        val rebooted = currentBoot != storedBoot || now < cpElapsed
        if (rebooted) {
            // Don't credit downtime: resume from the last known remaining.
            val remaining = p.getLong(KEY_CP_REMAINING, 0).coerceAtLeast(0)
            p.edit()
                .putLong(KEY_END_ELAPSED, now + remaining)
                .putInt(KEY_BOOT_COUNT, currentBoot)
                .putLong(KEY_CP_ELAPSED, now)
                .putLong(KEY_CP_REMAINING, remaining)
                .apply()
        }
    }

    /** Milliseconds left in the active session (0 if none / finished). */
    fun remainingMs(ctx: Context): Long {
        val p = prefs(ctx)
        if (!p.getBoolean(KEY_ACTIVE, false)) return 0
        ensureAnchored(ctx)
        val end = p.getLong(KEY_END_ELAPSED, 0)
        return (end - SystemClock.elapsedRealtime()).coerceAtLeast(0)
    }

    /** Writes a checkpoint so a reboot resumes from (roughly) here. */
    fun checkpoint(ctx: Context) {
        val p = prefs(ctx)
        if (!p.getBoolean(KEY_ACTIVE, false)) return
        p.edit()
            .putLong(KEY_CP_ELAPSED, SystemClock.elapsedRealtime())
            .putLong(KEY_CP_REMAINING, remainingMs(ctx))
            .apply()
    }

    /** Marks the session finished and leaves a pending completion flag. */
    fun complete(ctx: Context) {
        val p = prefs(ctx)
        val total = p.getLong(KEY_TOTAL, 0)
        p.edit()
            .putBoolean(KEY_ACTIVE, false)
            .putBoolean(KEY_PENDING, true)
            .putLong(KEY_PENDING_DURATION, total)
            .apply()
    }

    /** Clears the pending completion flag after the UI has shown it. */
    fun acknowledge(ctx: Context) {
        prefs(ctx).edit()
            .putBoolean(KEY_PENDING, false)
            .putLong(KEY_PENDING_DURATION, 0)
            .apply()
    }

    /** Builds the state map sent across the method / event channel. */
    fun stateMap(ctx: Context): Map<String, Any?> {
        val active = isActive(ctx)
        val pending = isPending(ctx)
        val status = when {
            active -> "active"
            pending -> "completed"
            else -> "idle"
        }
        return mapOf(
            "status" to status,
            "remainingMs" to remainingMs(ctx),
            "totalMs" to totalMs(ctx),
            "packages" to blockedPackages(ctx).toList(),
            "hasPendingCompletion" to pending,
            "completedDurationMs" to pendingDurationMs(ctx)
        )
    }

    // --- Love notes cache (shown by the native block screen) ---

    fun cacheLoveNotes(
        ctx: Context,
        notes: List<String>,
        completeNotes: List<String>,
        signature: String
    ) {
        ctx.applicationContext.getSharedPreferences(NOTES_PREFS, Context.MODE_PRIVATE)
            .edit()
            .putStringSet("notes", notes.toSet())
            .putStringSet("complete", completeNotes.toSet())
            .putString("signature", signature)
            .apply()
    }

    fun randomNote(ctx: Context): String {
        val p = ctx.applicationContext
            .getSharedPreferences(NOTES_PREFS, Context.MODE_PRIVATE)
        val notes = p.getStringSet("notes", emptySet())?.toList() ?: emptyList()
        if (notes.isEmpty()) return "Not now, Anis. You've got this. — Sirine"
        return notes.random()
    }

    fun signature(ctx: Context): String {
        val p = ctx.applicationContext
            .getSharedPreferences(NOTES_PREFS, Context.MODE_PRIVATE)
        return p.getString("signature", "— Sirine 💗") ?: "— Sirine"
    }
}
