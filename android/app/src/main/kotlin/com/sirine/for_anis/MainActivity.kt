package com.sirine.for_anis

import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Base64
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/**
 * Hosts the Flutter UI and bridges it to the native enforcement layer through
 * one [MethodChannel] (commands + queries) and one [EventChannel] (session
 * state stream).
 */
class MainActivity : FlutterActivity() {

    private val methodChannelName = "com.sirine.for_anis/focus"
    private val eventChannelName = "com.sirine.for_anis/focus_events"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getState" -> result.success(SessionStore.stateMap(this))

                "startSession" -> {
                    val durationMs = (call.argument<Number>("durationMs"))?.toLong() ?: 0L
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    SessionStore.start(this, durationMs, packages)
                    FocusForegroundService.start(this)
                    FocusEventBridge.emit(this)
                    result.success(true)
                }

                "acknowledgeCompletion" -> {
                    SessionStore.acknowledge(this)
                    FocusEventBridge.emit(this)
                    result.success(null)
                }

                "cacheLoveNotes" -> {
                    val notes = call.argument<List<String>>("notes") ?: emptyList()
                    val complete = call.argument<List<String>>("completeNotes") ?: emptyList()
                    val signature = call.argument<String>("signature") ?: "— Sirine"
                    SessionStore.cacheLoveNotes(this, notes, complete, signature)
                    result.success(null)
                }

                "checkPermissions" -> result.success(checkPermissions())

                "requestPermission" -> {
                    val permission = call.argument<String>("permission") ?: ""
                    requestPermission(permission)
                    result.success(null)
                }

                "getInstalledApps" -> getInstalledApps(result)

                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, eventChannelName).setStreamHandler(FocusEventBridge)
    }

    override fun onResume() {
        super.onResume()
        // Self-heal: if a session is active but the foreground service isn't
        // running (e.g. it was killed by the OS or an app update), bring it back.
        if (SessionStore.isActive(this)) {
            FocusForegroundService.start(this)
        }
    }

    // --- Permissions ---

    private fun checkPermissions(): Map<String, Boolean> {
        return mapOf(
            "accessibility" to isAccessibilityEnabled(),
            "deviceAdmin" to isDeviceAdminActive(),
            "usageAccess" to hasUsageAccess(),
            "overlay" to Settings.canDrawOverlays(this),
            "batteryOptimization" to isIgnoringBatteryOptimizations(),
            "notifications" to NotificationManagerCompat.from(this).areNotificationsEnabled()
        )
    }

    private fun isAccessibilityEnabled(): Boolean {
        val expected = FocusAccessibilityService.componentName(this).flattenToString()
        val enabled = Settings.Secure.getString(
            contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val on = Settings.Secure.getInt(
            contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0
        ) == 1
        return on && enabled.split(':').any {
            it.equals(expected, ignoreCase = true) ||
                (it.contains(packageName) && it.contains("FocusAccessibilityService"))
        }
    }

    private fun isDeviceAdminActive(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return dpm.isAdminActive(
            ComponentName(this, FocusDeviceAdminReceiver::class.java)
        )
    }

    private fun hasUsageAccess(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (_: Throwable) {
            false
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestPermission(permission: String) {
        when (permission) {
            "accessibility" ->
                startSafely(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))

            "deviceAdmin" -> {
                val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                    putExtra(
                        DevicePolicyManager.EXTRA_DEVICE_ADMIN,
                        ComponentName(this@MainActivity, FocusDeviceAdminReceiver::class.java)
                    )
                    putExtra(
                        DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                        "This keeps For Anis in place so a focus session can't be " +
                            "undone by uninstalling. 💗 — Sirine"
                    )
                }
                startSafely(intent)
            }

            "usageAccess" ->
                startSafely(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))

            "overlay" -> startSafely(
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
            )

            "batteryOptimization" -> startSafely(
                Intent(
                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    Uri.parse("package:$packageName")
                )
            )

            "notifications" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    ActivityCompat.requestPermissions(
                        this, arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 42
                    )
                } else {
                    val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    startSafely(intent)
                }
            }
        }
    }

    private fun startSafely(intent: Intent) {
        try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (_: Throwable) {
            try {
                startActivity(
                    Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.parse("package:$packageName")
                    ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                )
            } catch (_: Throwable) {
            }
        }
    }

    // --- Installed apps ---

    private fun getInstalledApps(result: MethodChannel.Result) {
        Thread {
            val apps = loadLaunchableApps()
            runOnUiThread { result.success(apps) }
        }.start()
    }

    private fun loadLaunchableApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolved = pm.queryIntentActivities(intent, 0)
        val seen = HashSet<String>()
        val apps = ArrayList<Map<String, Any?>>()
        for (info in resolved) {
            val pkg = info.activityInfo.packageName
            if (pkg == packageName || !seen.add(pkg)) continue
            val label = info.loadLabel(pm).toString()
            val isSystem = try {
                val appInfo = pm.getApplicationInfo(pkg, 0)
                (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
            } catch (_: Throwable) {
                false
            }
            val icon = try {
                encodeIcon(info.loadIcon(pm))
            } catch (_: Throwable) {
                ""
            }
            apps.add(
                mapOf(
                    "packageName" to pkg,
                    "appName" to label,
                    "isSystem" to isSystem,
                    "icon" to icon
                )
            )
        }
        apps.sortBy { (it["appName"] as String).lowercase() }
        return apps
    }

    private fun encodeIcon(drawable: Drawable): String {
        val size = 96
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            Bitmap.createScaledBitmap(drawable.bitmap, size, size, true)
        } else {
            val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }
}
