import 'package:cyber_vpn/features/session/data/models/ip_who_is_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'exit_ip_api.g.dart';

@RestApi(baseUrl: 'https://ipwho.is/')
abstract class ExitIpApi {
  factory ExitIpApi(Dio dio, {String? baseUrl}) = _ExitIpApi;

  @GET('/')
  Future<IpWhoIsResponse> lookup();
}
