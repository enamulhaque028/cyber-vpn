import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/locations/data/supabase_locations_repository.dart';
import 'package:cyber_vpn/features/locations/data/tcp_server_probe.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/server_probe.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/session/data/axe_vpn_tunnel_repository.dart';
import 'package:cyber_vpn/features/session/data/exit_ip_api.dart';
import 'package:cyber_vpn/features/session/data/ip_who_is_exit_ip_repository.dart';
import 'package:cyber_vpn/features/session/data/prefs_session_history_repository.dart';
import 'package:cyber_vpn/features/session/domain/repositories/exit_ip_repository.dart';
import 'package:cyber_vpn/features/session/domain/repositories/session_history_repository.dart';
import 'package:cyber_vpn/features/session/domain/repositories/tunnel_repository.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/exit_check_cubit.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/history_cubit.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:cyber_vpn/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {Headers.acceptHeader: Headers.jsonContentType},
        ),
      ),
    )
    ..registerLazySingleton<ExitIpApi>(
      () => ExitIpApi(getIt(), baseUrl: AppConfig.exitIpBaseUrl),
    )
    ..registerLazySingleton<LocationsRepository>(
      () => SupabaseLocationsRepository(getIt()),
    )
    ..registerLazySingleton<ServerProbe>(TcpServerProbe.new)
    ..registerLazySingleton<ExitIpRepository>(
      () => IpWhoIsExitIpRepository(getIt()),
    )
    ..registerLazySingleton<SessionHistoryRepository>(
      () => PrefsSessionHistoryRepository(getIt()),
    )
    ..registerLazySingleton<TunnelRepository>(AxeVpnTunnelRepository.new)
    ..registerFactory(() => ThemeCubit(getIt()))
    ..registerFactory(() => LocationsBloc(getIt(), getIt(), getIt()))
    ..registerFactory(() => ExitCheckCubit(getIt()))
    ..registerFactory(() => HistoryCubit(getIt()))
    ..registerFactory(
      () => SessionBloc(
        getIt<TunnelRepository>(),
        getIt<LocationsRepository>(),
        getIt<SharedPreferences>(),
        getIt<SessionHistoryRepository>(),
      ),
    );
}
