abstract class TunnelRepository {
  Future<void> initialize({
    required void Function(String stage) onStage,
    required void Function(String duration, String byteIn, String byteOut)
    onStatus,
  });

  Future<void> connect({
    required String config,
    required String notificationName,
    required String username,
    required String password,
    bool killSwitch = true,
    List<String> bypassPackages = const [],
  });

  Future<void> disconnect();

  /// Android 13+: request POST_NOTIFICATIONS so OpenVPN sticky bar can show.
  Future<bool> ensureNotificationPermission();

  /// Android: system VPN settings (Always-on). iOS: app settings.
  Future<void> openSystemVpnSettings();
}
