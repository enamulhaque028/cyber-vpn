import 'dart:convert';
import 'dart:io';

import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';

void main() {
  final raw = jsonDecode(File('fleet/catalog.json').readAsStringSync())
      as Map<String, dynamic>;
  final creds = VpnCredentials.fromJson(
    Map<String, dynamic>.from(raw['credentials'] as Map),
  );
  final servers = (raw['servers'] as List)
      .map((e) => VpnLocation.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  final ids = servers.map((s) => s.id).toSet();
  if (ids.length != servers.length) {
    stderr.writeln('duplicate stable ids');
    exit(1);
  }

  var seenGate = false;
  for (final s in servers) {
    if (s.source != 'vpnbook' && s.source != 'vpngate') {
      stderr.writeln('bad source on ${s.title}: ${s.source}');
      exit(1);
    }
    if (s.protocol != 'tcp' && s.protocol != 'udp' && s.protocol.isNotEmpty) {
      stderr.writeln('bad protocol on ${s.title}: ${s.protocol}');
      exit(1);
    }
    if (s.source == 'vpngate') {
      seenGate = true;
    } else if (seenGate) {
      stderr.writeln('vpnbook after vpngate: ${s.title}');
      exit(1);
    }
  }

  final countries = servers
      .where((s) => s.source == 'vpngate')
      .map((s) => s.country)
      .toSet();
  stdout.writeln(
    'ok credentials=${creds.username} servers=${servers.length} '
    'uniqueIds=${ids.length} '
    'vpnbook=${servers.where((s) => s.source == 'vpnbook').length} '
    'vpngate=${servers.where((s) => s.source == 'vpngate').length} '
    'tcp=${servers.where((s) => s.protocol == 'tcp').length} '
    'udp=${servers.where((s) => s.protocol == 'udp').length} '
    'vpngateCountries=${countries.length}',
  );
}
