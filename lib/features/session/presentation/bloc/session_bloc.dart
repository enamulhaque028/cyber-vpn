import 'dart:async';
import 'dart:math';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/core/network/connectivity_bloc.dart';
import 'package:cyber_vpn/core/utils/traffic_format.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:cyber_vpn/features/session/domain/entities/session_record.dart';
import 'package:cyber_vpn/features/session/domain/network_kind.dart';
import 'package:cyber_vpn/features/session/domain/repositories/session_history_repository.dart';
import 'package:cyber_vpn/features/session/domain/repositories/tunnel_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'session_bloc.freezed.dart';
part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(
    this._tunnel,
    this._locations,
    this._prefs,
    this._history,
    this._connectivityBloc,
  ) : super(
         SessionState(
           killSwitchEnabled: _prefs.getBool(AppConfig.prefsKillSwitch) ?? true,
           splitTunnelEnabled:
               _prefs.getBool(AppConfig.prefsSplitTunnelEnabled) ?? false,
           bypassPackages:
               _prefs.getStringList(AppConfig.prefsBypassPackages) ?? const [],
         ),
       ) {
    on<SessionStarted>(_onStarted);
    on<SessionConnectPressed>(_onConnect);
    on<SessionDisconnectPressed>(_onDisconnect);
    on<SessionServerChosen>(_onServerChosen);
    on<SessionStageUpdated>(_onStage);
    on<SessionStatusUpdated>(_onStatus);
    on<SessionConnectTimedOut>(_onConnectTimedOut);
    on<SessionKillSwitchChanged>(_onKillSwitchChanged);
    on<SessionSplitTunnelChanged>(_onSplitTunnelChanged);
    on<SessionBypassPackagesChanged>(_onBypassPackagesChanged);
    on<SessionNetworkPathChanged>(_onNetworkPathChanged);
    on<SessionOpenSystemVpnSettings>(_onOpenSystemVpnSettings);
  }

  final TunnelRepository _tunnel;
  final LocationsRepository _locations;
  final SharedPreferences _prefs;
  final SessionHistoryRepository _history;
  final ConnectivityBloc _connectivityBloc;
  bool _initialized = false;
  bool _intended = false;
  /// True while recycling the tunnel for kill-switch / bypass option changes.
  /// Suppresses stage-driven `_scheduleReconnect` so we do not double-connect.
  bool _recyclingTunnel = false;
  int _reconnectAttempts = 0;
  Timer? _connectTimer;
  Timer? _reconnectTimer;
  StreamSubscription<NetworkKind>? _connectivitySub;
  int? _lastBytesIn;
  int? _lastBytesOut;
  DateTime? _lastBytesAt;
  DateTime? _sessionStartedAt;
  int _sessionBytesIn = 0;
  int _sessionBytesOut = 0;
  String _sessionLocationName = '';
  int? _sessionLocationId;

  @override
  Future<void> close() {
    _connectTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }

  Future<void> _ensureTunnel() async {
    if (_initialized) return;
    await _tunnel.initialize(
      onStage: (stage) => add(SessionEvent.stageUpdated(stage)),
      onStatus: (d, i, o) =>
          add(SessionEvent.statusUpdated(duration: d, byteIn: i, byteOut: o)),
    );
    _initialized = true;
  }

  void _listenToConnectivity() {
    _connectivitySub ??= _connectivityBloc.stream
        .map((state) => state.kind)
        .distinct()
        .listen((kind) {
          add(SessionEvent.networkPathChanged(kind));
        });
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    _listenToConnectivity();
    try {
      await _ensureTunnel();
    } catch (e) {
      emit(state.copyWith(message: e.toString()));
    }

    var locations = event.locations;
    var creds = event.credentials ?? state.credentials;
    try {
      creds ??= await _locations.getCredentials();
      if (locations.isEmpty) {
        locations = await _locations.getLocations();
      }
    } catch (e) {
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          message: 'Could not load servers. Check your connection.',
        ),
      );
      return;
    }

    VpnLocation? selected = state.selected;
    if (locations.isNotEmpty) {
      final savedId = _prefs.getInt(AppConfig.prefsSelectedServerId);
      selected =
          locations.where((l) => l.id == savedId).firstOrNull ??
          selected ??
          locations.first;
    }

    emit(state.copyWith(selected: selected, credentials: creds, message: null));
  }

  Future<void> _onConnect(
    SessionConnectPressed event,
    Emitter<SessionState> emit,
  ) async {
    _intended = true;
    try {
      await _ensureTunnel();
    } catch (e) {
      _intended = false;
      emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
      return;
    }

    final kind = await _connectivityBloc.fetchCurrentKind();
    if (kind == NetworkKind.none) {
      _intended = false;
      _connectTimer?.cancel();
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          reconnecting: false,
          message: 'No internet connection. Check Wi‑Fi or mobile data.',
        ),
      );
      return;
    }

    var location = state.selected;
    var creds = state.credentials;
    if (location == null || creds == null) {
      try {
        creds ??= await _locations.getCredentials();
        if (location == null) {
          final locations = await _locations.getLocations();
          if (locations.isNotEmpty) {
            final savedId = _prefs.getInt(AppConfig.prefsSelectedServerId);
            location =
                locations.where((l) => l.id == savedId).firstOrNull ??
                locations.first;
          }
        }
        emit(state.copyWith(selected: location, credentials: creds));
      } catch (e) {
        emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
        return;
      }
    }

    location = state.selected;
    creds = state.credentials;
    if (location == null || creds == null) {
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          message: 'No server or credentials yet',
        ),
      );
      return;
    }
    if (location.config.trim().isEmpty) {
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          message: 'This location has no tunnel config.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: SessionPhase.connecting,
        reconnecting: _reconnectAttempts > 0,
        message: _reconnectAttempts > 0 ? 'Reconnecting…' : null,
      ),
    );
    try {
      await _tunnel.connect(
        config: location.config,
        notificationName: location.displayName,
        username: creds.username,
        password: creds.password,
        killSwitch: state.killSwitchEnabled,
        bypassPackages: _activeBypassPackages,
      );
      _armConnectTimeout();
    } catch (e) {
      _connectTimer?.cancel();
      emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
      _scheduleReconnect();
    }
  }

  Future<void> _finishSessionRecord() async {
    final started = _sessionStartedAt;
    final id = _sessionLocationId;
    if (started == null || id == null) return;
    final ended = DateTime.now();
    final bytesIn = _sessionDeltaIn;
    final bytesOut = _sessionDeltaOut;
    _sessionStartedAt = null;
    _sessionBytesIn = 0;
    _sessionBytesOut = 0;
    if (ended.difference(started).inSeconds < 3) return;
    try {
      await _history.add(
        SessionRecord(
          locationId: id,
          locationName: _sessionLocationName,
          startedAt: started,
          endedAt: ended,
          bytesIn: bytesIn,
          bytesOut: bytesOut,
        ),
      );
    } catch (_) {}
  }

  void _beginSessionRecord() {
    final loc = state.selected;
    _sessionStartedAt = DateTime.now();
    _sessionLocationId = loc?.id;
    _sessionLocationName = loc?.displayName ?? 'Unknown';
    // Baseline at connect; if status has not fired yet, treat later totals
    // as absolute session counters from 0.
    _sessionBytesIn = _lastBytesIn ?? 0;
    _sessionBytesOut = _lastBytesOut ?? 0;
  }

  int get _sessionDeltaIn =>
      ((_lastBytesIn ?? _sessionBytesIn) - _sessionBytesIn).clamp(0, 1 << 62);
  int get _sessionDeltaOut =>
      ((_lastBytesOut ?? _sessionBytesOut) - _sessionBytesOut).clamp(0, 1 << 62);

  void _armConnectTimeout() {
    _connectTimer?.cancel();
    final seconds = state.credentials?.connectionTimeoutSeconds ?? 30;
    _connectTimer = Timer(Duration(seconds: seconds), () {
      add(const SessionEvent.connectTimedOut());
    });
  }

  void _scheduleReconnect() {
    if (!_intended) return;
    _reconnectTimer?.cancel();
    if (_reconnectAttempts >= 5) {
      return;
    }
    final delaySeconds = min(8, 1 << _reconnectAttempts);
    _reconnectAttempts++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_intended) add(const SessionEvent.connectPressed());
    });
  }

  Future<void> _onConnectTimedOut(
    SessionConnectTimedOut event,
    Emitter<SessionState> emit,
  ) async {
    if (state.phase != SessionPhase.connecting) return;
    await _tunnel.disconnect();
    if (!state.didRefreshOnFailure) {
      emit(
        state.copyWith(
          didRefreshOnFailure: true,
          message: 'Refreshing servers…',
        ),
      );
      try {
        final creds = await _locations.getCredentials(forceRefresh: true);
        final locs = await _locations.getLocations(forceRefresh: true);
        VpnLocation? selected = state.selected;
        if (locs.isNotEmpty) {
          selected =
              locs.where((l) => l.id == selected?.id).firstOrNull ?? locs.first;
        }
        emit(state.copyWith(credentials: creds, selected: selected));
        add(const SessionEvent.connectPressed());
      } catch (e) {
        emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
      }
      return;
    }
    emit(
      state.copyWith(
        phase: SessionPhase.failed,
        reconnecting: false,
        message: 'Could not connect. Try another location.',
      ),
    );
    _scheduleReconnect();
  }

  Future<void> _onDisconnect(
    SessionDisconnectPressed event,
    Emitter<SessionState> emit,
  ) async {
    _intended = false;
    _recyclingTunnel = false;
    _reconnectAttempts = 0;
    _connectTimer?.cancel();
    _reconnectTimer?.cancel();
    // Finish before clearing byte counters — deltas use _lastBytes*.
    await _finishSessionRecord();
    _lastBytesIn = null;
    _lastBytesOut = null;
    _lastBytesAt = null;
    await _tunnel.disconnect();
    emit(
      state.copyWith(
        phase: SessionPhase.idle,
        duration: '00:00:00',
        reconnecting: false,
        message: null,
        downRate: '—',
        upRate: '—',
      ),
    );
  }

  Future<void> _onServerChosen(
    SessionServerChosen event,
    Emitter<SessionState> emit,
  ) async {
    await _prefs.setInt(AppConfig.prefsSelectedServerId, event.location.id);
    final wasOn =
        state.phase == SessionPhase.protected ||
        state.phase == SessionPhase.connecting;
    if (wasOn) {
      await _tunnel.disconnect();
    }
    emit(state.copyWith(selected: event.location, phase: SessionPhase.idle));
    if (wasOn) {
      add(const SessionEvent.connectPressed());
    }
  }

  Future<void> _onKillSwitchChanged(
    SessionKillSwitchChanged event,
    Emitter<SessionState> emit,
  ) async {
    await _prefs.setBool(AppConfig.prefsKillSwitch, event.enabled);
    emit(state.copyWith(killSwitchEnabled: event.enabled));
    await _reconnectIfProtecting();
  }

  Future<void> _onSplitTunnelChanged(
    SessionSplitTunnelChanged event,
    Emitter<SessionState> emit,
  ) async {
    if (event.enabled == state.splitTunnelEnabled) return;
    await _prefs.setBool(AppConfig.prefsSplitTunnelEnabled, event.enabled);
    emit(state.copyWith(splitTunnelEnabled: event.enabled));
    await _reconnectIfProtecting();
  }

  Future<void> _onBypassPackagesChanged(
    SessionBypassPackagesChanged event,
    Emitter<SessionState> emit,
  ) async {
    final packages = List<String>.from(event.packages)..sort();
    final previous = List<String>.from(state.bypassPackages);
    if (packages.length == previous.length &&
        packages.asMap().entries.every((e) => e.value == previous[e.key])) {
      return;
    }
    await _prefs.setStringList(AppConfig.prefsBypassPackages, packages);
    emit(state.copyWith(bypassPackages: packages));
    if (!state.splitTunnelEnabled) return;
    await _reconnectIfProtecting();
  }

  List<String> get _activeBypassPackages {
    if (!state.splitTunnelEnabled) return const [];
    return state.bypassPackages;
  }

  Future<void> _reconnectIfProtecting() async {
    if (!_intended) return;
    if (state.phase != SessionPhase.protected &&
        state.phase != SessionPhase.connecting) {
      return;
    }
    _connectTimer?.cancel();
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    _recyclingTunnel = true;
    await _tunnel.disconnect();
    add(const SessionEvent.connectPressed());
  }

  void _onNetworkPathChanged(
    SessionNetworkPathChanged event,
    Emitter<SessionState> emit,
  ) {
    if (!_intended) return;
    if (state.phase == SessionPhase.protected) return;
    if (state.phase == SessionPhase.connecting) return;
    _scheduleReconnect();
  }

  Future<void> _onOpenSystemVpnSettings(
    SessionOpenSystemVpnSettings event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _tunnel.openSystemVpnSettings();
    } catch (e) {
      emit(
        state.copyWith(
          message:
              'Open Settings → Network & internet → VPN. Enable Always-on and Block connections without VPN.',
        ),
      );
    }
  }

  Future<void> _onStage(
    SessionStageUpdated event,
    Emitter<SessionState> emit,
  ) async {
    final raw = event.stage.toLowerCase();
    if (raw.contains('connected') && !raw.contains('disconnected')) {
      _connectTimer?.cancel();
      _reconnectTimer?.cancel();
      _reconnectAttempts = 0;
      _recyclingTunnel = false;
      if (_sessionStartedAt == null) {
        _beginSessionRecord();
      }
      emit(
        state.copyWith(
          phase: SessionPhase.protected,
          didRefreshOnFailure: false,
          reconnecting: false,
          message: null,
        ),
      );
    } else if (raw.contains('reconnect')) {
      emit(
        state.copyWith(
          phase: SessionPhase.connecting,
          reconnecting: true,
          message: 'Reconnecting…',
        ),
      );
    } else if (raw.contains('connecting') || raw.contains('wait')) {
      emit(state.copyWith(phase: SessionPhase.connecting));
    } else if (raw.contains('denied')) {
      _intended = false;
      _recyclingTunnel = false;
      _reconnectTimer?.cancel();
      emit(state.copyWith(phase: SessionPhase.idle, reconnecting: false));
    } else if (raw.contains('disconnect') ||
        raw.contains('error') ||
        raw.contains('exit')) {
      if (!_intended) {
        _recyclingTunnel = false;
        await _finishSessionRecord();
        emit(
          state.copyWith(
            phase: SessionPhase.idle,
            reconnecting: false,
            duration: '00:00:00',
          ),
        );
        return;
      }
      if (_recyclingTunnel) {
        _recyclingTunnel = false;
        emit(
          state.copyWith(
            phase: SessionPhase.connecting,
            reconnecting: true,
            message: 'Applying settings…',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          phase: SessionPhase.connecting,
          reconnecting: true,
          message: state.killSwitchEnabled
              ? 'Tunnel dropped. Reconnecting…'
              : 'Reconnecting…',
        ),
      );
      _scheduleReconnect();
    }
  }

  void _onStatus(SessionStatusUpdated event, Emitter<SessionState> emit) {
    final now = DateTime.now();
    final incoming = parseTrafficBytes(event.byteIn);
    final outgoing = parseTrafficBytes(event.byteOut);
    var down = state.downRate;
    var up = state.upRate;
    if (_lastBytesIn != null &&
        _lastBytesOut != null &&
        _lastBytesAt != null) {
      final dt = now.difference(_lastBytesAt!).inMilliseconds / 1000;
      if (dt >= 0.5) {
        down = formatRate((incoming - _lastBytesIn!) / dt);
        up = formatRate((outgoing - _lastBytesOut!) / dt);
        _lastBytesIn = incoming;
        _lastBytesOut = outgoing;
        _lastBytesAt = now;
      }
    } else {
      _lastBytesIn = incoming;
      _lastBytesOut = outgoing;
      _lastBytesAt = now;
    }
    emit(
      state.copyWith(duration: event.duration, downRate: down, upRate: up),
    );
  }
}
