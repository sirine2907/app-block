package com.sirine.for_anis

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Holds the EventChannel sink so any component (the foreground service, the
 * accessibility service) can push a fresh session snapshot up to Flutter.
 *
 * The sink is only non-null while the Flutter UI is attached; when it's gone
 * the pushes are simply dropped and Flutter re-queries [SessionStore] on
 * resume.
 */
object FocusEventBridge : EventChannel.StreamHandler {

    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    /** Pushes the current session state to Flutter (if anyone is listening). */
    fun emit(ctx: Context) {
        val state = SessionStore.stateMap(ctx)
        val current = sink ?: return
        main.post { current.success(state) }
    }
}
