import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cyber_vpn/core/config/app_config.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Kill switch'),
            subtitle: Text(
              'Best-effort on this OpenVPN stack. Full always-on comes with the later fleet.',
            ),
            trailing: Switch(value: true, onChanged: null),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                    ),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      context.read<ThemeCubit>().setMode(s.first),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy policy'),
            onTap: () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl)),
          ),
          ListTile(
            title: const Text('Terms'),
            onTap: () => launchUrl(Uri.parse(AppConfig.termsUrl)),
          ),
        ],
      ),
    );
  }
}

@RoutePage()
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlimited protect',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All locations, no ads, more devices when accounts ship.',
              style: TextStyle(color: scheme.secondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            _PlanCard(
              title: 'Annual',
              price: '\$39.99',
              badge: 'Best value',
              highlighted: true,
            ),
            const SizedBox(height: 12),
            const _PlanCard(title: 'Monthly', price: '\$9.99'),
            const Spacer(),
            Text(
              'Purchases will use the store. Restore will land with RevenueCat in the next slice.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    this.badge,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String? badge;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? scheme.primary : scheme.outline,
          width: highlighted ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (badge != null)
                  Text(
                    badge!,
                    style: TextStyle(color: scheme.primary, fontSize: 12),
                  ),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
