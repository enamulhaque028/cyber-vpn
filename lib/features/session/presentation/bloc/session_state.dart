part of 'session_bloc.dart';

enum SessionPhase { idle, connecting, protected, failed }

@freezed
abstract class SessionState with _$SessionState {
  const SessionState._();

  const factory SessionState({
    @Default(SessionPhase.idle) SessionPhase phase,
    VpnLocation? selected,
    VpnCredentials? credentials,
    @Default('00:00:00') String duration,
    String? message,
    @Default(false) bool didRefreshOnFailure,
    @Default(true) bool killSwitchEnabled,
    @Default(false) bool splitTunnelEnabled,
    @Default([]) List<String> bypassPackages,
    @Default(false) bool reconnecting,
    @Default('—') String downRate,
    @Default('—') String upRate,
  }) = _SessionState;

  bool get isProtected => phase == SessionPhase.protected;
}
