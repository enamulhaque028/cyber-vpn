import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/core/network/connectivity_bloc.dart';
import 'package:cyber_vpn/core/theme/app_theme.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:cyber_vpn/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CyberVpnApp extends StatelessWidget {
  const CyberVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<ConnectivityBloc>()
                ..add(const ConnectivityEvent.started()),
          lazy: false,
        ),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(
          create: (_) =>
              getIt<LocationsBloc>()..add(const LocationsEvent.started()),
          lazy: false,
        ),
        BlocProvider(create: (_) => getIt<SessionBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            routerConfig: getIt<AppRouter>().config(),
          );
        },
      ),
    );
  }
}
