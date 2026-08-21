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
  stdout.writeln(
    'ok credentials=${creds.username} servers=${servers.length} '
    'uniqueIds=${ids.length}',
  );
}
