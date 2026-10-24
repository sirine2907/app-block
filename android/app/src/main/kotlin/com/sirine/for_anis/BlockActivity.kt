package com.sirine.for_anis

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat

/**
 * The full-screen, native block screen shown over a blocked app. It appears
 * instantly (no Flutter engine needed), shows the time left plus a love note
 * from the cached list, and gently sends Anis home. There is no way back to
 * the blocked app from here.
 */
class BlockActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timeLabel: TextView
    private lateinit var ticker: Runnable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val bg = ContextCompat.getColor(this, R.color.block_background)
        val textColor = ContextCompat.getColor(this, R.color.block_text)
        val accent = ContextCompat.getColor(this, R.color.block_accent)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(bg)
            val pad = dp(28)
            setPadding(pad, pad, pad, pad)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        val heart = TextView(this).apply {
            text = "💗"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 56f)
            gravity = Gravity.CENTER
        }

        val title = TextView(this).apply {
            text = "Not now, Anis"
            setTextColor(textColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 32f)
            typeface = Typeface.create("serif", Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(0, dp(16), 0, dp(8))
        }

        val note = TextView(this).apply {
            text = SessionStore.randomNote(this@BlockActivity)
            setTextColor(textColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 19f)
            typeface = Typeface.create("serif", Typeface.ITALIC)
            gravity = Gravity.CENTER
            setPadding(dp(8), 0, dp(8), dp(6))
        }

        val signature = TextView(this).apply {
            text = SessionStore.signature(this@BlockActivity)
            setTextColor(accent)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(28))
        }

        timeLabel = TextView(this).apply {
            setTextColor(accent)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
            typeface = Typeface.MONOSPACE
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(32))
        }

        val button = Button(this).apply {
            text = "Okay, back to focusing"
            setTextColor(Color.WHITE)
            setBackgroundColor(accent)
            setPadding(dp(24), dp(14), dp(24), dp(14))
            setOnClickListener { goHome() }
        }

        root.addView(heart)
        root.addView(title)
        root.addView(note)
        root.addView(signature)
        root.addView(timeLabel)
        root.addView(button)
        setContentView(root)

        ticker = Runnable { updateTime() }
        updateTime()
    }

    private fun updateTime() {
        if (!SessionStore.isActive(this)) {
            finish()
            return
        }
        val remaining = SessionStore.remainingMs(this)
        timeLabel.text = "${formatClock(remaining)} left"
        handler.postDelayed(ticker, 1000)
    }

    private fun goHome() {
        val home = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(home)
        finish()
    }

    @Deprecated("Routed to home instead of returning to the blocked app")
    override fun onBackPressed() {
        goHome()
    }

    override fun onDestroy() {
        handler.removeCallbacks(ticker)
        super.onDestroy()
    }

    private fun formatClock(ms: Long): String {
        val totalSeconds = ms / 1000
        val h = totalSeconds / 3600
        val m = (totalSeconds % 3600) / 60
        val s = totalSeconds % 60
        return "%02d:%02d:%02d".format(h, m, s)
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    companion object {
        const val EXTRA_PACKAGE = "package"
    }
}
