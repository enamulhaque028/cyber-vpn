import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyber_vpn/features/session/domain/network_kind.dart';

NetworkKind networkKindFromConnectivity(List<ConnectivityResult> results) {
  if (results.isEmpty ||
      (results.length == 1 && results.first == ConnectivityResult.none)) {
    return NetworkKind.none;
  }
  if (results.contains(ConnectivityResult.wifi)) return NetworkKind.wifi;
  if (results.contains(ConnectivityResult.mobile) ||
      results.contains(ConnectivityResult.ethernet)) {
    return NetworkKind.cellular;
  }
  return NetworkKind.other;
}
