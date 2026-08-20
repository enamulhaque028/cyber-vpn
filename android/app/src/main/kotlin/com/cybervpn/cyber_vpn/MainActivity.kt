package com.cybervpn.cyber_vpn

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.axevpn.flutter.openvpn.AxeVPNFlutterPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cybervpn.cyber_vpn/device",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openVpnSettings" -> {
                    if (openVpnSettings()) {
                        result.success(true)
                    } else {
                        result.error("UNAVAILABLE", "No VPN settings activity", null)
                    }
                }
                "listLaunchableApps" -> {
                    try {
                        result.success(listLaunchableApps())
                    } catch (e: Exception) {
                        result.error("APPS", e.message, null)
                    }
                }
                "ensureNotifications" -> ensureNotifications(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun ensureNotifications(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.POST_NOTIFICATIONS,
        ) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            result.success(true)
            return
        }
        if (pendingNotificationResult != null) {
            result.success(false)
            return
        }
        pendingNotificationResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST) return
        val ok = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingNotificationResult?.success(ok)
        pendingNotificationResult = null
    }

    private fun listLaunchableApps(): List<Map<String, String>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        @Suppress("DEPRECATION")
        val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(0),
            )
        } else {
            pm.queryIntentActivities(intent, 0)
        }
        val seen = HashSet<String>()
        val out = ArrayList<Map<String, String>>()
        for (info in resolved) {
            val packageName = info.activityInfo.packageName
            if (!seen.add(packageName)) continue
            val label = info.loadLabel(pm)?.toString() ?: packageName
            out.add(
                mapOf(
                    "packageName" to packageName,
                    "label" to label,
                ),
            )
        }
        out.sortBy { it["label"]?.lowercase() }
        return out
    }

    private fun openVpnSettings(): Boolean {
        val candidates = listOf(
            Intent(Settings.ACTION_VPN_SETTINGS),
            Intent("android.net.vpn.SETTINGS"),
            Intent(Settings.ACTION_WIRELESS_SETTINGS),
            Intent(Settings.ACTION_SETTINGS),
        )
        for (intent in candidates) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            try {
                startActivity(intent)
                return true
            } catch (_: Exception) {
                continue
            }
        }
        return false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        AxeVPNFlutterPlugin.connectWhileGranted(requestCode == 24 && resultCode == RESULT_OK)
        super.onActivityResult(requestCode, resultCode, data)
    }

    companion object {
        private const val NOTIFICATION_PERMISSION_REQUEST = 1001
    }
}
