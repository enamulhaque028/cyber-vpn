class AppConfig {
  AppConfig._();

  static const appName = 'Cyber VPN';
  static const supabaseUrl = 'https://coiahkfbvfhkebqickhz.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_SBLULdgEl4pZba5eHt_Lyw_hIGOZISe';
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
  static const prefsFavoriteServerIds = 'favorite_server_ids';
  static const prefsRecentServerIds = 'recent_server_ids';
  static const prefsSessionHistory = 'session_history';

  /// HTTPS exit lookup base (never use plain HTTP ip-api).
  static const exitIpBaseUrl = 'https://ipwho.is/';

  static const deviceSettingsChannel = 'com.cybervpn.cyber_vpn/device';

  /// iOS App Group + Packet Tunnel identifiers (must match Xcode).
  static const iosAppGroup = 'group.com.cybervpn.cyberVpn';
  static const iosVpnExtensionBundleId = 'com.cybervpn.cyberVpn.VPNExtension';
}
