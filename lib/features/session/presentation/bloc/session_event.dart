part of 'session_bloc.dart';

@freezed
sealed class SessionEvent with _$SessionEvent {
  const factory SessionEvent.started({
    @Default([]) List<VpnLocation> locations,
    VpnCredentials? credentials,
  }) = SessionStarted;
  const factory SessionEvent.connectPressed() = SessionConnectPressed;
  const factory SessionEvent.disconnectPressed() = SessionDisconnectPressed;
  const factory SessionEvent.serverChosen(VpnLocation location) =
      SessionServerChosen;
  const factory SessionEvent.stageUpdated(String stage) = SessionStageUpdated;
  const factory SessionEvent.statusUpdated({
    required String duration,
    required String byteIn,
    required String byteOut,
  }) = SessionStatusUpdated;
  const factory SessionEvent.connectTimedOut() = SessionConnectTimedOut;
  const factory SessionEvent.killSwitchChanged(bool enabled) =
      SessionKillSwitchChanged;
  const factory SessionEvent.splitTunnelChanged(bool enabled) =
      SessionSplitTunnelChanged;
  const factory SessionEvent.bypassPackagesChanged(List<String> packages) =
      SessionBypassPackagesChanged;
  const factory SessionEvent.networkPathChanged(NetworkKind kind) =
      SessionNetworkPathChanged;
  const factory SessionEvent.openSystemVpnSettings() =
      SessionOpenSystemVpnSettings;
}
