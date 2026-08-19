import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';

abstract class LocationsRepository {
  Future<VpnCredentials> getCredentials({bool forceRefresh = false});

  Future<List<VpnLocation>> getLocations({bool forceRefresh = false});
}
