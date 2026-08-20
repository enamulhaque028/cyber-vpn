import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/exit_check_cubit.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ConnectionInfoPage extends StatelessWidget {
  const ConnectionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExitCheckCubit>()..refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connection'),
          actions: [
            BlocBuilder<ExitCheckCubit, ExitCheckState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: state is ExitCheckLoading
                      ? null
                      : () => context.read<ExitCheckCubit>().refresh(),
                  icon: const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, session) {
            final loc = session.selected;
            final protected = session.phase == SessionPhase.protected;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Selected location'),
                  subtitle: Text(loc?.displayName ?? 'None'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Status'),
                  subtitle: Text(protected ? 'Protected' : 'Not protected'),
                ),
                const Divider(height: 32),
                Text(
                  'Exit check',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifies your public exit over HTTPS. Run while Protected. We do not store this IP.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<ExitCheckCubit, ExitCheckState>(
                  builder: (context, state) {
                    return switch (state) {
                      ExitCheckIdle() || ExitCheckLoading() => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      ExitCheckFailed(:final message) => Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      ExitCheckReady(:final info) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row(context, 'IP', info.ip),
                          _row(context, 'City', info.city),
                          _row(context, 'Country', info.country),
                          _row(context, 'ISP', info.isp),
                        ],
                      ),
                    };
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
