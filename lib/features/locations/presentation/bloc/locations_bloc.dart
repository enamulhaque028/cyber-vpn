import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'locations_bloc.freezed.dart';
part 'locations_event.dart';
part 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  LocationsBloc(this._repository) : super(const LocationsState.loading()) {
    on<LocationsStarted>(_onStarted);
    on<LocationsQueryChanged>(_onQuery);
  }

  final LocationsRepository _repository;

  Future<void> _onStarted(
    LocationsStarted event,
    Emitter<LocationsState> emit,
  ) async {
    emit(const LocationsState.loading());
    try {
      final credentials = await _repository.getCredentials(
        forceRefresh: event.forceRefresh,
      );
      final all = await _repository.getLocations(
        forceRefresh: event.forceRefresh,
      );
      emit(
        LocationsState.loaded(all: all, visible: all, credentials: credentials),
      );
    } catch (e) {
      emit(LocationsState.failure(e.toString()));
    }
  }

  void _onQuery(LocationsQueryChanged event, Emitter<LocationsState> emit) {
    final current = state;
    if (current is! LocationsLoaded) return;
    final q = event.query.toLowerCase();
    final visible = q.isEmpty
        ? current.all
        : current.all
              .where(
                (l) =>
                    l.country.toLowerCase().contains(q) ||
                    l.city.toLowerCase().contains(q) ||
                    l.title.toLowerCase().contains(q),
              )
              .toList();
    emit(current.copyWith(visible: visible, query: event.query));
  }
}
