import 'dart:io';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/session/domain/repositories/installed_apps_repository.dart';
import 'package:flutter/services.dart';

class DeviceInstalledAppsRepository implements InstalledAppsRepository {
  DeviceInstalledAppsRepository({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(AppConfig.deviceSettingsChannel);

  final MethodChannel _channel;

  @override
  Future<List<InstalledApp>> listLaunchable() async {
    if (!Platform.isAndroid) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>('listLaunchableApps');
    if (raw == null) return const [];
    final apps = <InstalledApp>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<Object?, Object?>.from(item);
      final packageName = map['packageName']?.toString() ?? '';
      final label = map['label']?.toString() ?? packageName;
      if (packageName.isEmpty) continue;
      if (packageName == AppConfig.androidApplicationId) continue;
      apps.add(InstalledApp(packageName: packageName, label: label));
    }
    apps.sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    return apps;
  }
}
