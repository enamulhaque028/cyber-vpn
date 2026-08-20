import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/features/session/domain/repositories/installed_apps_repository.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class BypassAppsPage extends StatefulWidget {
  const BypassAppsPage({super.key});

  @override
  State<BypassAppsPage> createState() => _BypassAppsPageState();
}

class _BypassAppsPageState extends State<BypassAppsPage> {
  late final Future<List<InstalledApp>> _appsFuture;
  final _query = TextEditingController();
  String _filter = '';
  Set<String>? _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _appsFuture = getIt<InstalledAppsRepository>().listLaunchable();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Set<String> _effectiveDraft(SessionState session) =>
      _draft ?? session.bypassPackages.toSet();

  bool _dirty(SessionState session) {
    final draft = _effectiveDraft(session);
    final saved = session.bypassPackages.toSet();
    return draft.length != saved.length || !draft.containsAll(saved);
  }

  Future<void> _save(BuildContext context, SessionState session) async {
    final draft = _effectiveDraft(session);
    if (!_dirty(session) || _saving) {
      if (context.mounted) context.router.maybePop();
      return;
    }
    setState(() => _saving = true);
    context.read<SessionBloc>().add(
      SessionEvent.bypassPackagesChanged(draft.toList()),
    );
    if (context.mounted) {
      await context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<SessionBloc, SessionState>(
      buildWhen: (p, n) => p.bypassPackages != n.bypassPackages,
      builder: (context, session) {
        final selected = _effectiveDraft(session);
        final dirty = _dirty(session);
        return PopScope(
          canPop: !dirty || _saving,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || _saving) return;
            final discard = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text(
                  'You have unsaved app selections.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep editing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Discard'),
                  ),
                ],
              ),
            );
            if (discard == true && context.mounted) {
              context.router.maybePop();
            }
          },
          child: Scaffold(
          appBar: AppBar(
            title: const Text('Apps that bypass VPN'),
            actions: [
              TextButton(
                onPressed: _saving ? null : () => _save(context, session),
                child: Text(dirty ? 'Save' : 'Done'),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Selected apps use Wi‑Fi or cellular while Protect is on. '
                  'Turn off Android “Block connections without VPN” or those apps '
                  'will have no internet. Tap Save to apply (reconnects if Protected).',
                  style: TextStyle(color: scheme.secondary, height: 1.35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _query,
                  onChanged: (v) =>
                      setState(() => _filter = v.trim().toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search apps',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<InstalledApp>>(
                  future: _appsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load apps.\n${snap.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    final all = snap.data ?? const <InstalledApp>[];
                    final visible = _filter.isEmpty
                        ? all
                        : all
                              .where(
                                (a) =>
                                    a.label.toLowerCase().contains(_filter) ||
                                    a.packageName.toLowerCase().contains(
                                      _filter,
                                    ),
                              )
                              .toList();
                    if (visible.isEmpty) {
                      return Center(
                        child: Text(
                          all.isEmpty
                              ? 'No launchable apps found.'
                              : 'No matches.',
                          style: TextStyle(color: scheme.secondary),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final app = visible[index];
                        final on = selected.contains(app.packageName);
                        return CheckboxListTile(
                          value: on,
                          title: Text(app.label),
                          subtitle: Text(
                            app.packageName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onChanged: _saving
                              ? null
                              : (v) {
                                  final next = Set<String>.from(selected);
                                  if (v == true) {
                                    next.add(app.packageName);
                                  } else {
                                    next.remove(app.packageName);
                                  }
                                  setState(() => _draft = next);
                                },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}
