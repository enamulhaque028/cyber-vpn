part of 'locations_bloc.dart';

@freezed
sealed class LocationsState with _$LocationsState {
  const factory LocationsState.loading() = LocationsLoading;
  const factory LocationsState.loaded({
    required List<VpnLocation> all,
    required List<VpnLocation> visible,
    VpnCredentials? credentials,
    @Default('') String query,
    @Default(<int, int?>{}) Map<int, int?> rttMs,
  }) = LocationsLoaded;
  const factory LocationsState.failure(String message) = LocationsFailure;
}
