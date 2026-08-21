class AppConfig {
  AppConfig._();

  static const appName = 'Cyber VPN';

  /// `owner/repo` for the published [fleet/catalog.json] on GitHub `main`.
  /// Must match the remote the fleet workflow pushes to.
  static const fleetGithubSlug = 'enamulhaque028/cyber-vpn';

  static const fleetCatalogUrl =
      'https://cdn.jsdelivr.net/gh/$fleetGithubSlug@main/fleet/catalog.json';
  static const fleetCatalogFallbackUrl =
      'https://raw.githubusercontent.com/$fleetGithubSlug/main/fleet/catalog.json';

  static const privacyPolicyUrl =
      'https://sites.google.com/view/audacityitvpn/privacy-policy?pli=1';
  static const termsUrl =
      'https://sites.google.com/view/audacityitvpn/terms-and-conditions';

  static const prefsThemeMode = 'theme_mode';
  static const prefsPrivacyAccepted = 'privacy_accepted';
  static const prefsSelectedServerId = 'selected_server_id';
  static const prefsCachedConfig = 'cached_vpn_config';
  static const prefsCachedServers = 'cached_vpn_servers';
  static const prefsKillSwitch = 'kill_switch';
  static const prefsSplitTunnelEnabled = 'split_tunnel_enabled';
  static const prefsBypassPackages = 'bypass_packages';
  static const prefsFavoriteServerIds = 'favorite_server_ids';
  static const prefsRecentServerIds = 'recent_server_ids';
  static const prefsSessionHistory = 'session_history';

  /// HTTPS exit lookup base (never use plain HTTP ip-api).
  static const exitIpBaseUrl = 'https://ipwho.is/';

  static const deviceSettingsChannel = 'com.cybervpn.cyber_vpn/device';
  static const androidApplicationId = 'com.cybervpn.cyber_vpn';

  /// iOS App Group + Packet Tunnel identifiers (must match Xcode).
  static const iosAppGroup = 'group.com.cybervpn.cyberVpn';
  static const iosVpnExtensionBundleId = 'com.cybervpn.cyberVpn.VPNExtension';
}
