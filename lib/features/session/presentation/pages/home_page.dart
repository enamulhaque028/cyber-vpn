import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/core/widgets/cl_button.dart';
import 'package:cyber_vpn/core/widgets/connect_ring.dart';
import 'package:cyber_vpn/core/widgets/stats_ticker.dart';
import 'package:cyber_vpn/core/widgets/threat_banner.dart';
import 'package:cyber_vpn/core/network/connectivity_bloc.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSession(context.read<LocationsBloc>().state);
    });
  }

  void _startSession(LocationsState state) {
    if (state is LocationsLoaded) {
      context.read<SessionBloc>().add(
        SessionEvent.started(
          locations: state.all,
          credentials: state.credentials,
        ),
      );
    } else {
      context.read<SessionBloc>().add(const SessionEvent.started());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConfig.appName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Connection',
            onPressed: () => context.router.push(const ConnectionInfoRoute()),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) => _startSession(state),
        child: BlocListener<SessionBloc, SessionState>(
          listenWhen: (prev, next) =>
              next.message != null && next.message != prev.message,
          listener: (context, session) {
            final message = session.message;
            if (message == null) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Reference layout: banner / centered hero / pinned actions.
                  // Scroll only on very short viewports where Spacers cannot fit.
                  final mustScroll = constraints.maxHeight < 520;

                  final banner = BlocBuilder<ConnectivityBloc, ConnectivityState>(
                    buildWhen: (p, n) => p.kind != n.kind,
                    builder: (context, connectivity) {
                      return BlocBuilder<SessionBloc, SessionState>(
                        buildWhen: (p, n) => p.phase != n.phase,
                        builder: (context, session) {
                          return ThreatBanner(
                            kind: connectivity.kind,
                            protected: session.phase == SessionPhase.protected,
                          );
                        },
                      );
                    },
                  );

                  final ring = BlocBuilder<SessionBloc, SessionState>(
                    builder: (context, session) {
                      final phase = switch (session.phase) {
                        SessionPhase.connecting => ConnectRingPhase.connecting,
                        SessionPhase.protected => ConnectRingPhase.protected,
                        _ => ConnectRingPhase.idle,
                      };
                      return ConnectRing(
                        phase: phase,
                        locationLabel: session.selected?.displayName,
                        onPressed: () {
                          final bloc = context.read<SessionBloc>();
                          if (session.phase == SessionPhase.protected ||
                              session.phase == SessionPhase.connecting) {
                            bloc.add(const SessionEvent.disconnectPressed());
                          } else {
                            bloc.add(const SessionEvent.connectPressed());
                          }
                        },
                      );
                    },
                  );

                  final subtitle = BlocBuilder<SessionBloc, SessionState>(
                    builder: (context, session) {
                      final text = switch (session.phase) {
                        SessionPhase.protected => 'This device is protected',
                        SessionPhase.connecting => null,
                        SessionPhase.failed =>
                          session.message ?? 'Could not connect',
                        SessionPhase.idle => 'Tap to protect this device',
                      };
                      if (text == null) return const SizedBox.shrink();
                      return Text(
                        text,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: session.phase == SessionPhase.failed
                              ? scheme.error
                              : scheme.secondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      );
                    },
                  );

                  final stats = BlocBuilder<SessionBloc, SessionState>(
                    buildWhen: (p, n) =>
                        p.duration != n.duration ||
                        p.downRate != n.downRate ||
                        p.upRate != n.upRate ||
                        p.phase != n.phase,
                    builder: (context, session) {
                      return StatsTicker(
                        duration: session.duration,
                        downRate: session.downRate,
                        upRate: session.upRate,
                        active: session.phase == SessionPhase.protected,
                      );
                    },
                  );

                  final location = BlocBuilder<SessionBloc, SessionState>(
                    builder: (context, session) {
                      final loc = session.selected;
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          onTap: () =>
                              context.router.push(const LocationsRoute()),
                          leading: CircleAvatar(
                            backgroundColor: scheme.surface,
                            child: Icon(Icons.public, color: scheme.primary),
                          ),
                          title: Text(
                            loc?.displayName ?? 'Choose location',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            loc == null
                                ? 'Best available'
                                : (loc.isPremium
                                      ? 'Premium location'
                                      : 'Free location'),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  );

                  final actions = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      location,
                      const SizedBox(height: 12),
                      ClButton(
                        label: 'Check connection',
                        variant: ClButtonVariant.ghost,
                        onPressed: () =>
                            context.router.push(const ConnectionInfoRoute()),
                      ),
                      const SizedBox(height: 8),
                      ClButton(
                        label: 'Speed test',
                        variant: ClButtonVariant.ghost,
                        onPressed: () =>
                            context.router.push(const SpeedTestRoute()),
                      ),
                      const SizedBox(height: 8),
                      ClButton(
                        label: 'Go Premium',
                        variant: ClButtonVariant.ghost,
                        onPressed: () =>
                            context.router.push(const PaywallRoute()),
                      ),
                    ],
                  );

                  if (mustScroll) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          banner,
                          const SizedBox(height: 16),
                          FittedBox(fit: BoxFit.scaleDown, child: ring),
                          const SizedBox(height: 12),
                          subtitle,
                          const SizedBox(height: 12),
                          stats,
                          const SizedBox(height: 16),
                          actions,
                        ],
                      ),
                    );
                  }

                  // Reference composition — no scroll when height is enough.
                  return Column(
                    children: [
                      banner,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: ring,
                              ),
                            ),
                            const SizedBox(height: 16),
                            subtitle,
                            const SizedBox(height: 14),
                            stats,
                          ],
                        ),
                      ),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
