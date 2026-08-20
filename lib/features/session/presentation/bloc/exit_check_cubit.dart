import 'package:cyber_vpn/features/session/domain/entities/exit_info.dart';
import 'package:cyber_vpn/features/session/domain/repositories/exit_ip_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exit_check_cubit.freezed.dart';

@freezed
sealed class ExitCheckState with _$ExitCheckState {
  const factory ExitCheckState.idle() = ExitCheckIdle;
  const factory ExitCheckState.loading() = ExitCheckLoading;
  const factory ExitCheckState.ready(ExitInfo info) = ExitCheckReady;
  const factory ExitCheckState.failed(String message) = ExitCheckFailed;
}

class ExitCheckCubit extends Cubit<ExitCheckState> {
  ExitCheckCubit(this._repository) : super(const ExitCheckState.idle());

  final ExitIpRepository _repository;

  Future<void> refresh() async {
    emit(const ExitCheckState.loading());
    try {
      final info = await _repository.lookup();
      emit(ExitCheckState.ready(info));
    } catch (_) {
      emit(
        const ExitCheckState.failed(
          'Could not verify exit. Try again while Protected.',
        ),
      );
    }
  }
}
