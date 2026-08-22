import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyber_vpn/core/network/network_kind_from.dart';
import 'package:cyber_vpn/features/session/domain/network_kind.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connectivity_bloc.freezed.dart';

@freezed
abstract class ConnectivityState with _$ConnectivityState {
  const ConnectivityState._();

  const factory ConnectivityState({
    @Default(NetworkKind.other) NetworkKind kind,
  }) = _ConnectivityState;

  bool get hasConnection => kind != NetworkKind.none;
}

@freezed
sealed class ConnectivityEvent with _$ConnectivityEvent {
  const factory ConnectivityEvent.started() = ConnectivityStarted;

  const factory ConnectivityEvent.refreshRequested() =
      ConnectivityRefreshRequested;

  const factory ConnectivityEvent.resultsReceived(
    List<ConnectivityResult> results,
  ) = ConnectivityResultsReceived;
}

/// App-wide network path from `connectivity_plus` (Wi‑Fi / cellular / none).
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(const ConnectivityState()) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityRefreshRequested>(_onRefreshRequested);
    on<ConnectivityResultsReceived>(_onResultsReceived);
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// One-shot read for connect / speed test gates; also updates [state].
  Future<NetworkKind> fetchCurrentKind() async {
    final results = await _connectivity.checkConnectivity();
    final kind = networkKindFromConnectivity(results);
    add(ConnectivityEvent.resultsReceived(results));
    return kind;
  }

  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      add(ConnectivityEvent.resultsReceived(results));
    });
    add(const ConnectivityEvent.refreshRequested());
  }

  Future<void> _onRefreshRequested(
    ConnectivityRefreshRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    final results = await _connectivity.checkConnectivity();
    add(ConnectivityEvent.resultsReceived(results));
  }

  void _onResultsReceived(
    ConnectivityResultsReceived event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityState(kind: networkKindFromConnectivity(event.results)));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
