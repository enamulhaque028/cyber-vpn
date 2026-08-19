package com.cybervpn.cyber_vpn

import android.content.Intent
import com.axevpn.flutter.openvpn.AxeVPNFlutterPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        AxeVPNFlutterPlugin.connectWhileGranted(requestCode == 24 && resultCode == RESULT_OK)
        super.onActivityResult(requestCode, resultCode, data)
    }
}
