/// Best-effort leak reduction on the current OpenVPN fleet.
///
/// Android still needs system Always-on + "Block connections without VPN"
/// for a hard block. This only patches client `.ovpn` with persist and
/// IPv6-block directives the server file often omits.
class OpenVpnKillSwitch {
  OpenVpnKillSwitch._();

  static const _wanted = <String, String>{
    'persist-tun': 'persist-tun',
    'persist-key': 'persist-key',
    'ping': 'ping 10',
    'ping-restart': 'ping-restart 60',
    'block-ipv6': 'block-ipv6',
  };

  static String apply(String config, {required bool enabled}) {
    if (!enabled) return config;
    final existing = <String>{};
    for (final line in config.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty ||
          trimmed.startsWith('#') ||
          trimmed.startsWith(';')) {
        continue;
      }
      existing.add(trimmed.split(RegExp(r'\s+')).first.toLowerCase());
    }
    final extras = <String>[];
    for (final entry in _wanted.entries) {
      if (!existing.contains(entry.key)) extras.add(entry.value);
    }
    if (extras.isEmpty) return config;
    return '${config.trimRight()}\n\n# cyber-vpn kill-switch\n${extras.join('\n')}\n';
  }
}
