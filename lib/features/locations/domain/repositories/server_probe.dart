abstract class ServerProbe {
  /// TCP connect time in ms, or null if unreachable. Must not log host/IP.
  Future<int?> measureMs(String ovpnConfig);
}
