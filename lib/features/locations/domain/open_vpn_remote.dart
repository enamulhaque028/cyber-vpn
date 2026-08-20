/// First usable `remote` in an OpenVPN client config. Host is not logged.
class OpenVpnRemote {
  const OpenVpnRemote(this.host, this.port, {this.proto = 'udp'});

  final String host;
  final int port;
  final String proto;

  static OpenVpnRemote? first(String config) {
    var fileProto = 'udp';
    final remotes = <OpenVpnRemote>[];
    for (final line in config.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty ||
          trimmed.startsWith('#') ||
          trimmed.startsWith(';')) {
        continue;
      }
      final parts = trimmed.split(RegExp(r'\s+'));
      final key = parts.first.toLowerCase();
      if (key == 'proto' && parts.length >= 2) {
        fileProto = parts[1].toLowerCase();
        continue;
      }
      if (key == 'remote' && parts.length >= 2) {
        final port = parts.length >= 3 ? int.tryParse(parts[2]) ?? 1194 : 1194;
        final proto = parts.length >= 4
            ? parts[3].toLowerCase()
            : fileProto;
        remotes.add(OpenVpnRemote(parts[1], port, proto: proto));
      }
    }
    if (remotes.isEmpty) return null;
    return remotes.where((r) => r.proto.contains('tcp')).firstOrNull ??
        remotes.first;
  }
}
