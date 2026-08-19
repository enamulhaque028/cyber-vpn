// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locations_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationsEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationsEvent()';
}


}

/// @nodoc
class $LocationsEventCopyWith<$Res>  {
$LocationsEventCopyWith(LocationsEvent _, $Res Function(LocationsEvent) __);
}


/// Adds pattern-matching-related methods to [LocationsEvent].
extension LocationsEventPatterns on LocationsEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocationsStarted value)?  started,TResult Function( LocationsQueryChanged value)?  queryChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocationsStarted() when started != null:
return started(_that);case LocationsQueryChanged() when queryChanged != null:
return queryChanged(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocationsStarted value)  started,required TResult Function( LocationsQueryChanged value)  queryChanged,}){
final _that = this;
switch (_that) {
case LocationsStarted():
return started(_that);case LocationsQueryChanged():
return queryChanged(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocationsStarted value)?  started,TResult? Function( LocationsQueryChanged value)?  queryChanged,}){
final _that = this;
switch (_that) {
case LocationsStarted() when started != null:
return started(_that);case LocationsQueryChanged() when queryChanged != null:
return queryChanged(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool forceRefresh)?  started,TResult Function( String query)?  queryChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocationsStarted() when started != null:
return started(_that.forceRefresh);case LocationsQueryChanged() when queryChanged != null:
return queryChanged(_that.query);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool forceRefresh)  started,required TResult Function( String query)  queryChanged,}) {final _that = this;
switch (_that) {
case LocationsStarted():
return started(_that.forceRefresh);case LocationsQueryChanged():
return queryChanged(_that.query);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool forceRefresh)?  started,TResult? Function( String query)?  queryChanged,}) {final _that = this;
switch (_that) {
case LocationsStarted() when started != null:
return started(_that.forceRefresh);case LocationsQueryChanged() when queryChanged != null:
return queryChanged(_that.query);case _:
  return null;

}
}

}

/// @nodoc


class LocationsStarted implements LocationsEvent {
  const LocationsStarted({this.forceRefresh = false});
  

@JsonKey() final  bool forceRefresh;

/// Create a copy of LocationsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationsStartedCopyWith<LocationsStarted> get copyWith => _$LocationsStartedCopyWithImpl<LocationsStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsStarted&&(identical(other.forceRefresh, forceRefresh) || other.forceRefresh == forceRefresh));
}


@override
int get hashCode => Object.hash(runtimeType,forceRefresh);

@override
String toString() {
  return 'LocationsEvent.started(forceRefresh: $forceRefresh)';
}


}

/// @nodoc
abstract mixin class $LocationsStartedCopyWith<$Res> implements $LocationsEventCopyWith<$Res> {
  factory $LocationsStartedCopyWith(LocationsStarted value, $Res Function(LocationsStarted) _then) = _$LocationsStartedCopyWithImpl;
@useResult
$Res call({
 bool forceRefresh
});




}
/// @nodoc
class _$LocationsStartedCopyWithImpl<$Res>
    implements $LocationsStartedCopyWith<$Res> {
  _$LocationsStartedCopyWithImpl(this._self, this._then);

  final LocationsStarted _self;
  final $Res Function(LocationsStarted) _then;

/// Create a copy of LocationsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? forceRefresh = null,}) {
  return _then(LocationsStarted(
forceRefresh: null == forceRefresh ? _self.forceRefresh : forceRefresh // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class LocationsQueryChanged implements LocationsEvent {
  const LocationsQueryChanged(this.query);
  

 final  String query;

/// Create a copy of LocationsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationsQueryChangedCopyWith<LocationsQueryChanged> get copyWith => _$LocationsQueryChangedCopyWithImpl<LocationsQueryChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsQueryChanged&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'LocationsEvent.queryChanged(query: $query)';
}


}

/// @nodoc
abstract mixin class $LocationsQueryChangedCopyWith<$Res> implements $LocationsEventCopyWith<$Res> {
  factory $LocationsQueryChangedCopyWith(LocationsQueryChanged value, $Res Function(LocationsQueryChanged) _then) = _$LocationsQueryChangedCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$LocationsQueryChangedCopyWithImpl<$Res>
    implements $LocationsQueryChangedCopyWith<$Res> {
  _$LocationsQueryChangedCopyWithImpl(this._self, this._then);

  final LocationsQueryChanged _self;
  final $Res Function(LocationsQueryChanged) _then;

/// Create a copy of LocationsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(LocationsQueryChanged(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LocationsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationsState()';
}


}

/// @nodoc
class $LocationsStateCopyWith<$Res>  {
$LocationsStateCopyWith(LocationsState _, $Res Function(LocationsState) __);
}


/// Adds pattern-matching-related methods to [LocationsState].
extension LocationsStatePatterns on LocationsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocationsLoading value)?  loading,TResult Function( LocationsLoaded value)?  loaded,TResult Function( LocationsFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocationsLoading() when loading != null:
return loading(_that);case LocationsLoaded() when loaded != null:
return loaded(_that);case LocationsFailure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocationsLoading value)  loading,required TResult Function( LocationsLoaded value)  loaded,required TResult Function( LocationsFailure value)  failure,}){
final _that = this;
switch (_that) {
case LocationsLoading():
return loading(_that);case LocationsLoaded():
return loaded(_that);case LocationsFailure():
return failure(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocationsLoading value)?  loading,TResult? Function( LocationsLoaded value)?  loaded,TResult? Function( LocationsFailure value)?  failure,}){
final _that = this;
switch (_that) {
case LocationsLoading() when loading != null:
return loading(_that);case LocationsLoaded() when loaded != null:
return loaded(_that);case LocationsFailure() when failure != null:
return failure(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<VpnLocation> all,  List<VpnLocation> visible,  VpnCredentials? credentials,  String query)?  loaded,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocationsLoading() when loading != null:
return loading();case LocationsLoaded() when loaded != null:
return loaded(_that.all,_that.visible,_that.credentials,_that.query);case LocationsFailure() when failure != null:
return failure(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<VpnLocation> all,  List<VpnLocation> visible,  VpnCredentials? credentials,  String query)  loaded,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case LocationsLoading():
return loading();case LocationsLoaded():
return loaded(_that.all,_that.visible,_that.credentials,_that.query);case LocationsFailure():
return failure(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<VpnLocation> all,  List<VpnLocation> visible,  VpnCredentials? credentials,  String query)?  loaded,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case LocationsLoading() when loading != null:
return loading();case LocationsLoaded() when loaded != null:
return loaded(_that.all,_that.visible,_that.credentials,_that.query);case LocationsFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class LocationsLoading implements LocationsState {
  const LocationsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationsState.loading()';
}


}




/// @nodoc


class LocationsLoaded implements LocationsState {
  const LocationsLoaded({required final  List<VpnLocation> all, required final  List<VpnLocation> visible, this.credentials, this.query = ''}): _all = all,_visible = visible;
  

 final  List<VpnLocation> _all;
 List<VpnLocation> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

 final  List<VpnLocation> _visible;
 List<VpnLocation> get visible {
  if (_visible is EqualUnmodifiableListView) return _visible;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_visible);
}

 final  VpnCredentials? credentials;
@JsonKey() final  String query;

/// Create a copy of LocationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationsLoadedCopyWith<LocationsLoaded> get copyWith => _$LocationsLoadedCopyWithImpl<LocationsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsLoaded&&const DeepCollectionEquality().equals(other._all, _all)&&const DeepCollectionEquality().equals(other._visible, _visible)&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_all),const DeepCollectionEquality().hash(_visible),credentials,query);

@override
String toString() {
  return 'LocationsState.loaded(all: $all, visible: $visible, credentials: $credentials, query: $query)';
}


}

/// @nodoc
abstract mixin class $LocationsLoadedCopyWith<$Res> implements $LocationsStateCopyWith<$Res> {
  factory $LocationsLoadedCopyWith(LocationsLoaded value, $Res Function(LocationsLoaded) _then) = _$LocationsLoadedCopyWithImpl;
@useResult
$Res call({
 List<VpnLocation> all, List<VpnLocation> visible, VpnCredentials? credentials, String query
});


$VpnCredentialsCopyWith<$Res>? get credentials;

}
/// @nodoc
class _$LocationsLoadedCopyWithImpl<$Res>
    implements $LocationsLoadedCopyWith<$Res> {
  _$LocationsLoadedCopyWithImpl(this._self, this._then);

  final LocationsLoaded _self;
  final $Res Function(LocationsLoaded) _then;

/// Create a copy of LocationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? all = null,Object? visible = null,Object? credentials = freezed,Object? query = null,}) {
  return _then(LocationsLoaded(
all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<VpnLocation>,visible: null == visible ? _self._visible : visible // ignore: cast_nullable_to_non_nullable
as List<VpnLocation>,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as VpnCredentials?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of LocationsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnCredentialsCopyWith<$Res>? get credentials {
    if (_self.credentials == null) {
    return null;
  }

  return $VpnCredentialsCopyWith<$Res>(_self.credentials!, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}

/// @nodoc


class LocationsFailure implements LocationsState {
  const LocationsFailure(this.message);
  

 final  String message;

/// Create a copy of LocationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationsFailureCopyWith<LocationsFailure> get copyWith => _$LocationsFailureCopyWithImpl<LocationsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationsFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LocationsState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $LocationsFailureCopyWith<$Res> implements $LocationsStateCopyWith<$Res> {
  factory $LocationsFailureCopyWith(LocationsFailure value, $Res Function(LocationsFailure) _then) = _$LocationsFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$LocationsFailureCopyWithImpl<$Res>
    implements $LocationsFailureCopyWith<$Res> {
  _$LocationsFailureCopyWithImpl(this._self, this._then);

  final LocationsFailure _self;
  final $Res Function(LocationsFailure) _then;

/// Create a copy of LocationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(LocationsFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
