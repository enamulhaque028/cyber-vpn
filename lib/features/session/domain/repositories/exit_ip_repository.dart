import 'package:cyber_vpn/features/session/domain/entities/exit_info.dart';

abstract class ExitIpRepository {
  /// Fetches public exit IP geo over HTTPS. Must not log the IP.
  Future<ExitInfo> lookup();
}
