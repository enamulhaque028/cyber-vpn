import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/core/widgets/cl_button.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    context.read<LocationsBloc>().add(const LocationsEvent.started());
    final prefs = getIt<SharedPreferences>();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final accepted = prefs.getBool(AppConfig.prefsPrivacyAccepted) ?? false;
    if (accepted) {
      context.router.replace(const HomeRoute());
    } else {
      context.router.replace(const PrivacyRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Protect this network',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Before you connect',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cyber VPN encrypts traffic to a tunnel endpoint. We do not sell your data. Connection diagnostics stay on-device except crash reports you allow later.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.secondary,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              ClButton(
                label: 'Agree and continue',
                onPressed: () async {
                  await getIt<SharedPreferences>().setBool(
                    AppConfig.prefsPrivacyAccepted,
                    true,
                  );
                  if (context.mounted) {
                    context.router.replace(const HomeRoute());
                  }
                },
              ),
              const SizedBox(height: 12),
              ClButton(
                label: 'Privacy policy',
                variant: ClButtonVariant.ghost,
                onPressed: () =>
                    launchUrl(Uri.parse(AppConfig.privacyPolicyUrl)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
