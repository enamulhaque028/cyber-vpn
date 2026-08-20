import 'package:cyber_vpn/features/session/data/exit_ip_api.dart';
import 'package:cyber_vpn/features/session/domain/entities/exit_info.dart';
import 'package:cyber_vpn/features/session/domain/repositories/exit_ip_repository.dart';

class IpWhoIsExitIpRepository implements ExitIpRepository {
  IpWhoIsExitIpRepository(this._api);

  final ExitIpApi _api;

  @override
  Future<ExitInfo> lookup() async {
    final parsed = await _api.lookup();
    if (!parsed.success) {
      throw StateError('Exit check unavailable');
    }
    final isp = parsed.connection?.isp.trim() ?? '';
    return ExitInfo(
      ip: parsed.ip,
      city: parsed.city,
      country: parsed.country,
      isp: isp.isEmpty ? 'Unknown ISP' : isp,
    );
  }
}
