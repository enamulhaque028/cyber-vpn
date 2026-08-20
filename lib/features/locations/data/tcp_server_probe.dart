import 'dart:io';

import 'package:cyber_vpn/features/locations/domain/open_vpn_remote.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/server_probe.dart';

class TcpServerProbe implements ServerProbe {
  TcpServerProbe({this.timeout = const Duration(milliseconds: 1800)});

  final Duration timeout;

  @override
  Future<int?> measureMs(String ovpnConfig) async {
    final remote = OpenVpnRemote.first(ovpnConfig);
    if (remote == null) return null;
    final ports = <int>{
      if (remote.proto.contains('tcp')) remote.port,
      443,
      remote.port,
    };
    for (final port in ports) {
      final ms = await _connect(remote.host, port);
      if (ms != null) return ms;
    }
    return null;
  }

  Future<int?> _connect(String host, int port) async {
    final watch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      final ms = watch.elapsedMilliseconds;
      socket.destroy();
      return ms;
    } catch (_) {
      return null;
    }
  }
}
