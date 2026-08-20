import 'package:cyber_vpn/features/session/domain/entities/session_record.dart';
import 'package:cyber_vpn/features/session/domain/repositories/session_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_cubit.freezed.dart';

@freezed
sealed class HistoryState with _$HistoryState {
  const factory HistoryState.loading() = HistoryLoading;
  const factory HistoryState.loaded(List<SessionRecord> records) =
      HistoryLoaded;
  const factory HistoryState.failed(String message) = HistoryFailed;
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository) : super(const HistoryState.loading()) {
    refresh();
  }

  final SessionHistoryRepository _repository;

  Future<void> refresh() async {
    emit(const HistoryState.loading());
    try {
      emit(HistoryState.loaded(await _repository.list()));
    } catch (_) {
      emit(const HistoryState.failed('Could not load history.'));
    }
  }

  Future<void> clear() async {
    await _repository.clear();
    emit(const HistoryState.loaded([]));
  }
}
