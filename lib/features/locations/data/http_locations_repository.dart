import 'dart:convert';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FleetCatalog {
  const _FleetCatalog({required this.credentials, required this.servers});

  final VpnCredentials credentials;
  final List<VpnLocation> servers;
}

/// Fetches [AppConfig.fleetCatalogUrl] (jsDelivr) with raw GitHub fallback.
class HttpLocationsRepository implements LocationsRepository {
  HttpLocationsRepository(this._prefs, [Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 15),
              headers: {Headers.acceptHeader: Headers.jsonContentType},
            ),
          );

  final SharedPreferences _prefs;
  final Dio _dio;

  VpnCredentials? _credentials;
  List<VpnLocation>? _locations;
  Future<_FleetCatalog>? _inflight;
  String? _etag;

  @override
  Future<VpnCredentials> getCredentials({bool forceRefresh = false}) async {
    final catalog = await _loadCatalog(forceRefresh: forceRefresh);
    return catalog.credentials;
  }

  @override
  Future<List<VpnLocation>> getLocations({bool forceRefresh = false}) async {
    final catalog = await _loadCatalog(forceRefresh: forceRefresh);
    return catalog.servers;
  }

  Future<_FleetCatalog> _loadCatalog({required bool forceRefresh}) async {
    if (!forceRefresh) {
      if (_credentials != null && _locations != null) {
        return _FleetCatalog(credentials: _credentials!, servers: _locations!);
      }
      final fromPrefs = _readPrefsCatalog();
      if (fromPrefs != null) {
        _credentials = fromPrefs.credentials;
        _locations = fromPrefs.servers;
        return fromPrefs;
      }
    }

    final existing = _inflight;
    if (existing != null) return existing;

    final future = _fetchCatalog();
    _inflight = future;
    try {
      return await future;
    } finally {
      if (identical(_inflight, future)) {
        _inflight = null;
      }
    }
  }

  Future<_FleetCatalog> _fetchCatalog() async {
    try {
      final catalog = await _downloadCatalog();
      _credentials = catalog.credentials;
      _locations = catalog.servers;
      await _writePrefs(catalog);
      return catalog;
    } catch (_) {
      if (_credentials != null && _locations != null) {
        return _FleetCatalog(credentials: _credentials!, servers: _locations!);
      }
      final fromPrefs = _readPrefsCatalog();
      if (fromPrefs != null) {
        _credentials = fromPrefs.credentials;
        _locations = fromPrefs.servers;
        return fromPrefs;
      }
      rethrow;
    }
  }

  @override
  Future<({VpnCredentials credentials, List<VpnLocation> servers})>
  syncFromNetwork() async {
    final catalog = await _downloadCatalog();
    if (catalog.servers.isEmpty) {
      throw StateError('Catalog contained no servers');
    }
    _credentials = catalog.credentials;
    _locations = catalog.servers;
    await _writePrefs(catalog);
    return (credentials: catalog.credentials, servers: catalog.servers);
  }

  Future<_FleetCatalog> _downloadCatalog() async {
    DioException? lastError;
    for (final url in [
      AppConfig.fleetCatalogUrl,
      AppConfig.fleetCatalogFallbackUrl,
    ]) {
      try {
        final headers = <String, dynamic>{};
        if (_etag != null) {
          headers['if-none-match'] = _etag;
        }
        final response = await _dio.get<String>(
          url,
          options: Options(
            headers: headers,
            responseType: ResponseType.plain,
            validateStatus: (code) =>
                code != null && (code == 304 || (code >= 200 && code < 300)),
          ),
        );
        if (response.statusCode == 304 &&
            _credentials != null &&
            _locations != null) {
          return _FleetCatalog(
            credentials: _credentials!,
            servers: _locations!,
          );
        }
        final etag = response.headers.value('etag');
        if (etag != null && etag.isNotEmpty) {
          _etag = etag;
        }
        final body = response.data;
        if (body == null || body.isEmpty) {
          throw FormatException('Empty fleet catalog from $url');
        }
        return _parseCatalog(jsonDecode(body));
      } on DioException catch (e) {
        lastError = e;
      }
    }
    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: AppConfig.fleetCatalogUrl),
          message: 'Fleet catalog fetch failed',
        );
  }

  _FleetCatalog _parseCatalog(dynamic data) {
    final Map<String, dynamic> map;
    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is Map) {
      map = Map<String, dynamic>.from(data);
    } else if (data is String) {
      map = Map<String, dynamic>.from(jsonDecode(data) as Map);
    } else {
      throw FormatException(
        'Unexpected fleet catalog payload: ${data.runtimeType}',
      );
    }

    final credsRaw = map['credentials'];
    if (credsRaw is! Map) {
      throw const FormatException('Fleet catalog missing credentials');
    }
    final serversRaw = map['servers'];
    if (serversRaw is! List) {
      throw const FormatException('Fleet catalog missing servers');
    }

    final credentials = VpnCredentials.fromJson(
      Map<String, dynamic>.from(credsRaw),
    );
    final servers = serversRaw
        .map((e) => VpnLocation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return _FleetCatalog(credentials: credentials, servers: servers);
  }

  _FleetCatalog? _readPrefsCatalog() {
    final credsCached = _prefs.getString(AppConfig.prefsCachedConfig);
    final serversCached = _prefs.getString(AppConfig.prefsCachedServers);
    if (credsCached == null ||
        credsCached.isEmpty ||
        serversCached == null ||
        serversCached.isEmpty) {
      return null;
    }
    try {
      final credentials = VpnCredentials.fromJson(
        jsonDecode(credsCached) as Map<String, dynamic>,
      );
      final list = jsonDecode(serversCached) as List<dynamic>;
      final servers = list
          .map((e) => VpnLocation.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (servers.isEmpty) return null;
      return _FleetCatalog(credentials: credentials, servers: servers);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writePrefs(_FleetCatalog catalog) async {
    await _prefs.setString(
      AppConfig.prefsCachedConfig,
      jsonEncode(catalog.credentials.toJson()),
    );
    if (catalog.servers.isNotEmpty) {
      await _prefs.setString(
        AppConfig.prefsCachedServers,
        jsonEncode(catalog.servers.map((e) => e.toJson()).toList()),
      );
    }
  }
}
