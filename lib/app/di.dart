import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/features/locations/data/supabase_locations_repository.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/session/data/axe_vpn_tunnel_repository.dart';
import 'package:cyber_vpn/features/session/domain/repositories/tunnel_repository.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:cyber_vpn/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerLazySingleton<LocationsRepository>(
      () => SupabaseLocationsRepository(getIt()),
    )
    ..registerLazySingleton<TunnelRepository>(AxeVpnTunnelRepository.new)
    ..registerFactory(() => ThemeCubit(getIt()))
    ..registerFactory(() => LocationsBloc(getIt()))
    ..registerFactory(
      () => SessionBloc(
        getIt<TunnelRepository>(),
        getIt<LocationsRepository>(),
        getIt<SharedPreferences>(),
      ),
    );
}
