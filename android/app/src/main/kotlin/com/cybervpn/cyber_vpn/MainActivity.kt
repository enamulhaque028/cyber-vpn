package com.cybervpn.cyber_vpn

import android.content.Intent
import android.provider.Settings
import com.axevpn.flutter.openvpn.AxeVPNFlutterPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cybervpn.cyber_vpn/device",
        ).setMethodCallHandler { call, result ->
            if (call.method == "openVpnSettings") {
                if (openVpnSettings()) {
                    result.success(true)
                } else {
                    result.error("UNAVAILABLE", "No VPN settings activity", null)
                }
            } else {
                result.notImplemented()
            }
        }
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
}
