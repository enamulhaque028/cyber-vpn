import 'dart:convert';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLocationsRepository implements LocationsRepository {
  SupabaseLocationsRepository(this._prefs);

  final SharedPreferences _prefs;
  VpnCredentials? _credentials;
  List<VpnLocation>? _locations;

  @override
  Future<VpnCredentials> getCredentials({bool forceRefresh = false}) async {
    if (!forceRefresh && _credentials != null) return _credentials!;
    if (!forceRefresh) {
      final cached = _prefs.getString(AppConfig.prefsCachedConfig);
      if (cached != null && cached.isNotEmpty) {
        _credentials = VpnCredentials.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
        return _credentials!;
      }
    }

    try {
      final data =
          await Supabase.instance.client.from('vpn_config').select() as List;
      final creds = VpnCredentials.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
      _credentials = creds;
      await _prefs.setString(
        AppConfig.prefsCachedConfig,
        jsonEncode(creds.toJson()),
      );
      return creds;
    } catch (_) {
      if (_credentials != null) return _credentials!;
      final cached = _prefs.getString(AppConfig.prefsCachedConfig);
      if (cached != null) {
        return VpnCredentials.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<VpnLocation>> getLocations({bool forceRefresh = false}) async {
    if (!forceRefresh && _locations != null) return _locations!;
    if (!forceRefresh) {
      final cached = _prefs.getString(AppConfig.prefsCachedServers);
      if (cached != null && cached.isNotEmpty) {
        final list = jsonDecode(cached) as List<dynamic>;
        _locations = list
            .map(
              (e) => VpnLocation.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        return _locations!;
      }
    }

    try {
      final response = await Supabase.instance.client
          .from('vpn_servers')
          .select()
          .order('isPremium', ascending: false)
          .order('country', ascending: false);
      final locations = (response as List)
          .map((e) => VpnLocation.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _locations = locations;
      if (locations.isNotEmpty) {
        await _prefs.setString(
          AppConfig.prefsCachedServers,
          jsonEncode(locations.map((e) => e.toJson()).toList()),
        );
      }
      return locations;
    } catch (_) {
      if (_locations != null) return _locations!;
      final cached = _prefs.getString(AppConfig.prefsCachedServers);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list
            .map(
              (e) => VpnLocation.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      rethrow;
    }
  }
}
