part of 'locations_bloc.dart';

@freezed
sealed class LocationsEvent with _$LocationsEvent {
  const factory LocationsEvent.started({@Default(false) bool forceRefresh}) =
      LocationsStarted;
  const factory LocationsEvent.queryChanged(String query) =
      LocationsQueryChanged;
}
