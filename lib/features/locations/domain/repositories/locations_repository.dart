import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';

abstract class LocationsRepository {
  Future<VpnCredentials> getCredentials({bool forceRefresh = false});

  Future<List<VpnLocation>> getLocations({bool forceRefresh = false});

  /// Force a network fetch and update cache.
  ///
  /// Throws if jsDelivr and raw GitHub both fail, or if the catalog has no
  /// servers. Existing memory/prefs are left unchanged on failure.
  Future<({VpnCredentials credentials, List<VpnLocation> servers})>
  syncFromNetwork();
}
