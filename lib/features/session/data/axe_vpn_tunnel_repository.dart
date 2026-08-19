import 'dart:io';

import 'package:axevpn_flutter/openvpn_flutter.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/session/domain/open_vpn_kill_switch.dart';
import 'package:cyber_vpn/features/session/domain/repositories/tunnel_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AxeVpnTunnelRepository implements TunnelRepository {
  OpenVPN? _engine;
  static const _device = MethodChannel(AppConfig.deviceSettingsChannel);

  @override
  Future<void> initialize({
    required void Function(String stage) onStage,
    required void Function(String duration, String byteIn, String byteOut)
    onStatus,
  }) async {
    _engine = OpenVPN(
      onVpnStatusChanged: (status) {
        if (status == null) return;
        onStatus(
          status.duration ?? '00:00:00',
          status.byteIn ?? '0',
          status.byteOut ?? '0',
        );
      },
      onVpnStageChanged: (stage, raw) {
        onStage(stage.name);
      },
    );

    await _engine!.initialize(
      groupIdentifier: AppConfig.iosAppGroup,
      providerBundleIdentifier: AppConfig.iosVpnExtensionBundleId,
      localizedDescription: AppConfig.appName,
      lastStage: (stage) => onStage(stage.name),
      lastStatus: (status) {
        onStatus(
          status.duration ?? '00:00:00',
          status.byteIn ?? '0',
          status.byteOut ?? '0',
        );
      },
    );
  }

  @override
  Future<void> connect({
    required String config,
    required String country,
    required String username,
    required String password,
    bool killSwitch = true,
  }) async {
    final engine = _engine;
    if (engine == null) {
      throw StateError('Tunnel not initialized');
    }
    final ovpn = OpenVpnKillSwitch.apply(config, enabled: killSwitch);
    debugPrint('Connecting OpenVPN via axevpn_flutter');
    try {
      await engine.connect(
        ovpn,
        country,
        username: username,
        password: password,
        certIsRequired: true,
      );
    } catch (e) {
      throw StateError('Could not start tunnel: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _engine?.disconnect();
  }

  @override
  Future<void> openSystemVpnSettings() async {
    if (Platform.isAndroid) {
      final ok = await _device.invokeMethod<bool>('openVpnSettings');
      if (ok == true) return;
      throw StateError('Could not open VPN settings');
    }
    final launched = await launchUrl(Uri.parse('app-settings:'));
    if (!launched) {
      throw StateError('Could not open settings');
    }
  }
}
