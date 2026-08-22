import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpeedTestConnectionPill extends StatelessWidget {
  const SpeedTestConnectionPill({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, session) {
        final scheme = Theme.of(context).colorScheme;
        final protected = session.phase == SessionPhase.protected;
        final loc = session.selected;

        final label = protected
            ? (loc != null ? 'Protected · ${loc.placeName}' : 'Protected')
            : 'Direct (no VPN)';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                protected ? Icons.shield_rounded : Icons.public_rounded,
                size: 18,
                color: protected ? scheme.primary : scheme.secondary,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
