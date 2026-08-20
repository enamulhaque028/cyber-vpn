import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:cyber_vpn/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<SessionBloc, SessionState>(
            buildWhen: (p, n) => p.killSwitchEnabled != n.killSwitchEnabled,
            builder: (context, session) {
              return SwitchListTile(
                title: const Text('Kill switch'),
                subtitle: const Text(
                  'If the tunnel drops, reconnect immediately and block IPv6 leak on this OpenVPN stack. For a hard block on Android, also enable Always-on below.',
                ),
                value: session.killSwitchEnabled,
                onChanged: (v) => context.read<SessionBloc>().add(
                  SessionEvent.killSwitchChanged(v),
                ),
              );
            },
          ),
          if (defaultTargetPlatform == TargetPlatform.android) ...[
            BlocBuilder<SessionBloc, SessionState>(
              buildWhen: (p, n) =>
                  p.splitTunnelEnabled != n.splitTunnelEnabled ||
                  p.bypassPackages != n.bypassPackages,
              builder: (context, session) {
                final count = session.bypassPackages.length;
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Bypass selected apps'),
                      subtitle: const Text(
                        'Android only. Chosen apps skip the VPN (exclude list). '
                        'Conflicts with “Block connections without VPN” — turn Block off, or bypassed apps get no internet.',
                      ),
                      value: session.splitTunnelEnabled,
                      onChanged: (v) async {
                        if (v) {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Use with Block off'),
                              content: const Text(
                                'Bypassed apps leave the VPN on purpose. '
                                'If Android “Block connections without VPN” is on, '
                                'those apps will have no internet. Continue?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Enable'),
                                ),
                              ],
                            ),
                          );
                          if (ok != true || !context.mounted) return;
                        }
                        context.read<SessionBloc>().add(
                          SessionEvent.splitTunnelChanged(v),
                        );
                      },
                    ),
                    ListTile(
                      enabled: session.splitTunnelEnabled,
                      title: const Text('Choose apps'),
                      subtitle: Text(
                        count == 0
                            ? 'None selected'
                            : '$count app${count == 1 ? '' : 's'} bypass VPN',
                        style: TextStyle(color: scheme.secondary),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: session.splitTunnelEnabled
                          ? () => context.router.push(const BypassAppsRoute())
                          : null,
                    ),
                  ],
                );
              },
            ),
          ],
          if (defaultTargetPlatform == TargetPlatform.android)
            ListTile(
              title: const Text('Always-on VPN'),
              subtitle: Text(
                'Open Android VPN settings, choose Cyber VPN, then turn on Always-on VPN and (optionally) Block connections without VPN. That is the real leak block; the in-app switch cannot freeze the whole device. Do not use Block together with app bypass — bypassed apps would get no internet.',
                style: TextStyle(color: scheme.secondary),
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => context.read<SessionBloc>().add(
                const SessionEvent.openSystemVpnSettings(),
              ),
            )
          else
            ListTile(
              title: const Text('Stay protected on iOS'),
              subtitle: Text(
                'The extension reconnects when Wi-Fi or cellular returns. Kill switch keeps the TUN up and blocks IPv6. Full On Demand is a later slice. Per-app VPN is not available on the App Store.',
                style: TextStyle(color: scheme.secondary),
              ),
            ),
          const ListTile(
            title: Text('Auto-reconnect'),
            subtitle: Text(
              'While Protect is on, a drop or network change retries the same location (up to 5 times).',
            ),
          ),
          ListTile(
            title: const Text('Usage history'),
            subtitle: Text(
              'On-device session time and data. No browsing destinations.',
              style: TextStyle(color: scheme.secondary),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.router.push(const HistoryRoute()),
          ),
          ListTile(
            title: const Text('Connection check'),
            subtitle: Text(
              'HTTPS exit city / ISP while Protected.',
              style: TextStyle(color: scheme.secondary),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.router.push(const ConnectionInfoRoute()),
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
