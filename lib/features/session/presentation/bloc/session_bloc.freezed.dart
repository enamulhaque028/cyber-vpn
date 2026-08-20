// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionEvent()';
}


}

/// @nodoc
class $SessionEventCopyWith<$Res>  {
$SessionEventCopyWith(SessionEvent _, $Res Function(SessionEvent) __);
}


/// Adds pattern-matching-related methods to [SessionEvent].
extension SessionEventPatterns on SessionEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SessionStarted value)?  started,TResult Function( SessionConnectPressed value)?  connectPressed,TResult Function( SessionDisconnectPressed value)?  disconnectPressed,TResult Function( SessionServerChosen value)?  serverChosen,TResult Function( SessionStageUpdated value)?  stageUpdated,TResult Function( SessionStatusUpdated value)?  statusUpdated,TResult Function( SessionConnectTimedOut value)?  connectTimedOut,TResult Function( SessionKillSwitchChanged value)?  killSwitchChanged,TResult Function( SessionNetworkPathChanged value)?  networkPathChanged,TResult Function( SessionOpenSystemVpnSettings value)?  openSystemVpnSettings,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SessionStarted() when started != null:
return started(_that);case SessionConnectPressed() when connectPressed != null:
return connectPressed(_that);case SessionDisconnectPressed() when disconnectPressed != null:
return disconnectPressed(_that);case SessionServerChosen() when serverChosen != null:
return serverChosen(_that);case SessionStageUpdated() when stageUpdated != null:
return stageUpdated(_that);case SessionStatusUpdated() when statusUpdated != null:
return statusUpdated(_that);case SessionConnectTimedOut() when connectTimedOut != null:
return connectTimedOut(_that);case SessionKillSwitchChanged() when killSwitchChanged != null:
return killSwitchChanged(_that);case SessionNetworkPathChanged() when networkPathChanged != null:
return networkPathChanged(_that);case SessionOpenSystemVpnSettings() when openSystemVpnSettings != null:
return openSystemVpnSettings(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SessionStarted value)  started,required TResult Function( SessionConnectPressed value)  connectPressed,required TResult Function( SessionDisconnectPressed value)  disconnectPressed,required TResult Function( SessionServerChosen value)  serverChosen,required TResult Function( SessionStageUpdated value)  stageUpdated,required TResult Function( SessionStatusUpdated value)  statusUpdated,required TResult Function( SessionConnectTimedOut value)  connectTimedOut,required TResult Function( SessionKillSwitchChanged value)  killSwitchChanged,required TResult Function( SessionNetworkPathChanged value)  networkPathChanged,required TResult Function( SessionOpenSystemVpnSettings value)  openSystemVpnSettings,}){
final _that = this;
switch (_that) {
case SessionStarted():
return started(_that);case SessionConnectPressed():
return connectPressed(_that);case SessionDisconnectPressed():
return disconnectPressed(_that);case SessionServerChosen():
return serverChosen(_that);case SessionStageUpdated():
return stageUpdated(_that);case SessionStatusUpdated():
return statusUpdated(_that);case SessionConnectTimedOut():
return connectTimedOut(_that);case SessionKillSwitchChanged():
return killSwitchChanged(_that);case SessionNetworkPathChanged():
return networkPathChanged(_that);case SessionOpenSystemVpnSettings():
return openSystemVpnSettings(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SessionStarted value)?  started,TResult? Function( SessionConnectPressed value)?  connectPressed,TResult? Function( SessionDisconnectPressed value)?  disconnectPressed,TResult? Function( SessionServerChosen value)?  serverChosen,TResult? Function( SessionStageUpdated value)?  stageUpdated,TResult? Function( SessionStatusUpdated value)?  statusUpdated,TResult? Function( SessionConnectTimedOut value)?  connectTimedOut,TResult? Function( SessionKillSwitchChanged value)?  killSwitchChanged,TResult? Function( SessionNetworkPathChanged value)?  networkPathChanged,TResult? Function( SessionOpenSystemVpnSettings value)?  openSystemVpnSettings,}){
final _that = this;
switch (_that) {
case SessionStarted() when started != null:
return started(_that);case SessionConnectPressed() when connectPressed != null:
return connectPressed(_that);case SessionDisconnectPressed() when disconnectPressed != null:
return disconnectPressed(_that);case SessionServerChosen() when serverChosen != null:
return serverChosen(_that);case SessionStageUpdated() when stageUpdated != null:
return stageUpdated(_that);case SessionStatusUpdated() when statusUpdated != null:
return statusUpdated(_that);case SessionConnectTimedOut() when connectTimedOut != null:
return connectTimedOut(_that);case SessionKillSwitchChanged() when killSwitchChanged != null:
return killSwitchChanged(_that);case SessionNetworkPathChanged() when networkPathChanged != null:
return networkPathChanged(_that);case SessionOpenSystemVpnSettings() when openSystemVpnSettings != null:
return openSystemVpnSettings(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<VpnLocation> locations,  VpnCredentials? credentials)?  started,TResult Function()?  connectPressed,TResult Function()?  disconnectPressed,TResult Function( VpnLocation location)?  serverChosen,TResult Function( String stage)?  stageUpdated,TResult Function( String duration,  String byteIn,  String byteOut)?  statusUpdated,TResult Function()?  connectTimedOut,TResult Function( bool enabled)?  killSwitchChanged,TResult Function( NetworkKind kind)?  networkPathChanged,TResult Function()?  openSystemVpnSettings,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SessionStarted() when started != null:
return started(_that.locations,_that.credentials);case SessionConnectPressed() when connectPressed != null:
return connectPressed();case SessionDisconnectPressed() when disconnectPressed != null:
return disconnectPressed();case SessionServerChosen() when serverChosen != null:
return serverChosen(_that.location);case SessionStageUpdated() when stageUpdated != null:
return stageUpdated(_that.stage);case SessionStatusUpdated() when statusUpdated != null:
return statusUpdated(_that.duration,_that.byteIn,_that.byteOut);case SessionConnectTimedOut() when connectTimedOut != null:
return connectTimedOut();case SessionKillSwitchChanged() when killSwitchChanged != null:
return killSwitchChanged(_that.enabled);case SessionNetworkPathChanged() when networkPathChanged != null:
return networkPathChanged(_that.kind);case SessionOpenSystemVpnSettings() when openSystemVpnSettings != null:
return openSystemVpnSettings();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<VpnLocation> locations,  VpnCredentials? credentials)  started,required TResult Function()  connectPressed,required TResult Function()  disconnectPressed,required TResult Function( VpnLocation location)  serverChosen,required TResult Function( String stage)  stageUpdated,required TResult Function( String duration,  String byteIn,  String byteOut)  statusUpdated,required TResult Function()  connectTimedOut,required TResult Function( bool enabled)  killSwitchChanged,required TResult Function( NetworkKind kind)  networkPathChanged,required TResult Function()  openSystemVpnSettings,}) {final _that = this;
switch (_that) {
case SessionStarted():
return started(_that.locations,_that.credentials);case SessionConnectPressed():
return connectPressed();case SessionDisconnectPressed():
return disconnectPressed();case SessionServerChosen():
return serverChosen(_that.location);case SessionStageUpdated():
return stageUpdated(_that.stage);case SessionStatusUpdated():
return statusUpdated(_that.duration,_that.byteIn,_that.byteOut);case SessionConnectTimedOut():
return connectTimedOut();case SessionKillSwitchChanged():
return killSwitchChanged(_that.enabled);case SessionNetworkPathChanged():
return networkPathChanged(_that.kind);case SessionOpenSystemVpnSettings():
return openSystemVpnSettings();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<VpnLocation> locations,  VpnCredentials? credentials)?  started,TResult? Function()?  connectPressed,TResult? Function()?  disconnectPressed,TResult? Function( VpnLocation location)?  serverChosen,TResult? Function( String stage)?  stageUpdated,TResult? Function( String duration,  String byteIn,  String byteOut)?  statusUpdated,TResult? Function()?  connectTimedOut,TResult? Function( bool enabled)?  killSwitchChanged,TResult? Function( NetworkKind kind)?  networkPathChanged,TResult? Function()?  openSystemVpnSettings,}) {final _that = this;
switch (_that) {
case SessionStarted() when started != null:
return started(_that.locations,_that.credentials);case SessionConnectPressed() when connectPressed != null:
return connectPressed();case SessionDisconnectPressed() when disconnectPressed != null:
return disconnectPressed();case SessionServerChosen() when serverChosen != null:
return serverChosen(_that.location);case SessionStageUpdated() when stageUpdated != null:
return stageUpdated(_that.stage);case SessionStatusUpdated() when statusUpdated != null:
return statusUpdated(_that.duration,_that.byteIn,_that.byteOut);case SessionConnectTimedOut() when connectTimedOut != null:
return connectTimedOut();case SessionKillSwitchChanged() when killSwitchChanged != null:
return killSwitchChanged(_that.enabled);case SessionNetworkPathChanged() when networkPathChanged != null:
return networkPathChanged(_that.kind);case SessionOpenSystemVpnSettings() when openSystemVpnSettings != null:
return openSystemVpnSettings();case _:
  return null;

}
}

}

/// @nodoc


class SessionStarted implements SessionEvent {
  const SessionStarted({final  List<VpnLocation> locations = const [], this.credentials}): _locations = locations;
  

 final  List<VpnLocation> _locations;
@JsonKey() List<VpnLocation> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}

 final  VpnCredentials? credentials;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStartedCopyWith<SessionStarted> get copyWith => _$SessionStartedCopyWithImpl<SessionStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionStarted&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.credentials, credentials) || other.credentials == credentials));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_locations),credentials);

@override
String toString() {
  return 'SessionEvent.started(locations: $locations, credentials: $credentials)';
}


}

/// @nodoc
abstract mixin class $SessionStartedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $SessionStartedCopyWith(SessionStarted value, $Res Function(SessionStarted) _then) = _$SessionStartedCopyWithImpl;
@useResult
$Res call({
 List<VpnLocation> locations, VpnCredentials? credentials
});


$VpnCredentialsCopyWith<$Res>? get credentials;

}
/// @nodoc
class _$SessionStartedCopyWithImpl<$Res>
    implements $SessionStartedCopyWith<$Res> {
  _$SessionStartedCopyWithImpl(this._self, this._then);

  final SessionStarted _self;
  final $Res Function(SessionStarted) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locations = null,Object? credentials = freezed,}) {
  return _then(SessionStarted(
locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<VpnLocation>,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as VpnCredentials?,
  ));
}

/// Create a copy of SessionEvent
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


class SessionConnectPressed implements SessionEvent {
  const SessionConnectPressed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionConnectPressed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionEvent.connectPressed()';
}


}




/// @nodoc


class SessionDisconnectPressed implements SessionEvent {
  const SessionDisconnectPressed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDisconnectPressed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionEvent.disconnectPressed()';
}


}




/// @nodoc


class SessionServerChosen implements SessionEvent {
  const SessionServerChosen(this.location);
  

 final  VpnLocation location;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionServerChosenCopyWith<SessionServerChosen> get copyWith => _$SessionServerChosenCopyWithImpl<SessionServerChosen>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionServerChosen&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode => Object.hash(runtimeType,location);

@override
String toString() {
  return 'SessionEvent.serverChosen(location: $location)';
}


}

/// @nodoc
abstract mixin class $SessionServerChosenCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $SessionServerChosenCopyWith(SessionServerChosen value, $Res Function(SessionServerChosen) _then) = _$SessionServerChosenCopyWithImpl;
@useResult
$Res call({
 VpnLocation location
});


$VpnLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$SessionServerChosenCopyWithImpl<$Res>
    implements $SessionServerChosenCopyWith<$Res> {
  _$SessionServerChosenCopyWithImpl(this._self, this._then);

  final SessionServerChosen _self;
  final $Res Function(SessionServerChosen) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(SessionServerChosen(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as VpnLocation,
  ));
}

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnLocationCopyWith<$Res> get location {
  
  return $VpnLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

/// @nodoc


class SessionStageUpdated implements SessionEvent {
  const SessionStageUpdated(this.stage);
  

 final  String stage;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStageUpdatedCopyWith<SessionStageUpdated> get copyWith => _$SessionStageUpdatedCopyWithImpl<SessionStageUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionStageUpdated&&(identical(other.stage, stage) || other.stage == stage));
}


@override
int get hashCode => Object.hash(runtimeType,stage);

@override
String toString() {
  return 'SessionEvent.stageUpdated(stage: $stage)';
}


}

/// @nodoc
abstract mixin class $SessionStageUpdatedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $SessionStageUpdatedCopyWith(SessionStageUpdated value, $Res Function(SessionStageUpdated) _then) = _$SessionStageUpdatedCopyWithImpl;
@useResult
$Res call({
 String stage
});




}
/// @nodoc
class _$SessionStageUpdatedCopyWithImpl<$Res>
    implements $SessionStageUpdatedCopyWith<$Res> {
  _$SessionStageUpdatedCopyWithImpl(this._self, this._then);

  final SessionStageUpdated _self;
  final $Res Function(SessionStageUpdated) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stage = null,}) {
  return _then(SessionStageUpdated(
null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SessionStatusUpdated implements SessionEvent {
  const SessionStatusUpdated({required this.duration, required this.byteIn, required this.byteOut});
  

 final  String duration;
 final  String byteIn;
 final  String byteOut;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStatusUpdatedCopyWith<SessionStatusUpdated> get copyWith => _$SessionStatusUpdatedCopyWithImpl<SessionStatusUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionStatusUpdated&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.byteIn, byteIn) || other.byteIn == byteIn)&&(identical(other.byteOut, byteOut) || other.byteOut == byteOut));
}


@override
int get hashCode => Object.hash(runtimeType,duration,byteIn,byteOut);

@override
String toString() {
  return 'SessionEvent.statusUpdated(duration: $duration, byteIn: $byteIn, byteOut: $byteOut)';
}


}

/// @nodoc
abstract mixin class $SessionStatusUpdatedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $SessionStatusUpdatedCopyWith(SessionStatusUpdated value, $Res Function(SessionStatusUpdated) _then) = _$SessionStatusUpdatedCopyWithImpl;
@useResult
$Res call({
 String duration, String byteIn, String byteOut
});




}
/// @nodoc
class _$SessionStatusUpdatedCopyWithImpl<$Res>
    implements $SessionStatusUpdatedCopyWith<$Res> {
  _$SessionStatusUpdatedCopyWithImpl(this._self, this._then);

  final SessionStatusUpdated _self;
  final $Res Function(SessionStatusUpdated) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? duration = null,Object? byteIn = null,Object? byteOut = null,}) {
  return _then(SessionStatusUpdated(
duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,byteIn: null == byteIn ? _self.byteIn : byteIn // ignore: cast_nullable_to_non_nullable
as String,byteOut: null == byteOut ? _self.byteOut : byteOut // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SessionConnectTimedOut implements SessionEvent {
  const SessionConnectTimedOut();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionConnectTimedOut);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionEvent.connectTimedOut()';
}


}




/// @nodoc


class SessionKillSwitchChanged implements SessionEvent {
  const SessionKillSwitchChanged(this.enabled);
  

 final  bool enabled;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionKillSwitchChangedCopyWith<SessionKillSwitchChanged> get copyWith => _$SessionKillSwitchChangedCopyWithImpl<SessionKillSwitchChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionKillSwitchChanged&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'SessionEvent.killSwitchChanged(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $SessionKillSwitchChangedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $SessionKillSwitchChangedCopyWith(SessionKillSwitchChanged value, $Res Function(SessionKillSwitchChanged) _then) = _$SessionKillSwitchChangedCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$SessionKillSwitchChangedCopyWithImpl<$Res>
    implements $SessionKillSwitchChangedCopyWith<$Res> {
  _$SessionKillSwitchChangedCopyWithImpl(this._self, this._then);

  final SessionKillSwitchChanged _self;
  final $Res Function(SessionKillSwitchChanged) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(SessionKillSwitchChanged(
null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SessionNetworkPathChanged implements SessionEvent {
  const SessionNetworkPathChanged(this.kind);
  

 final  NetworkKind kind;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionNetworkPathChangedCopyWith<SessionNetworkPathChanged> get copyWith => _$SessionNetworkPathChangedCopyWithImpl<SessionNetworkPathChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionNetworkPathChanged&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,kind);

@override
String toString() {
  return 'SessionEvent.networkPathChanged(kind: $kind)';
}


}

/// @nodoc
abstract mixin class $SessionNetworkPathChangedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $SessionNetworkPathChangedCopyWith(SessionNetworkPathChanged value, $Res Function(SessionNetworkPathChanged) _then) = _$SessionNetworkPathChangedCopyWithImpl;
@useResult
$Res call({
 NetworkKind kind
});




}
/// @nodoc
class _$SessionNetworkPathChangedCopyWithImpl<$Res>
    implements $SessionNetworkPathChangedCopyWith<$Res> {
  _$SessionNetworkPathChangedCopyWithImpl(this._self, this._then);

  final SessionNetworkPathChanged _self;
  final $Res Function(SessionNetworkPathChanged) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(SessionNetworkPathChanged(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NetworkKind,
  ));
}


}

/// @nodoc


class SessionOpenSystemVpnSettings implements SessionEvent {
  const SessionOpenSystemVpnSettings();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionOpenSystemVpnSettings);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionEvent.openSystemVpnSettings()';
}


}




/// @nodoc
mixin _$SessionState {

 SessionPhase get phase; VpnLocation? get selected; VpnCredentials? get credentials; String get duration; String? get message; bool get didRefreshOnFailure; bool get killSwitchEnabled; bool get reconnecting; NetworkKind get networkKind; String get downRate; String get upRate;
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStateCopyWith<SessionState> get copyWith => _$SessionStateCopyWithImpl<SessionState>(this as SessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.message, message) || other.message == message)&&(identical(other.didRefreshOnFailure, didRefreshOnFailure) || other.didRefreshOnFailure == didRefreshOnFailure)&&(identical(other.killSwitchEnabled, killSwitchEnabled) || other.killSwitchEnabled == killSwitchEnabled)&&(identical(other.reconnecting, reconnecting) || other.reconnecting == reconnecting)&&(identical(other.networkKind, networkKind) || other.networkKind == networkKind)&&(identical(other.downRate, downRate) || other.downRate == downRate)&&(identical(other.upRate, upRate) || other.upRate == upRate));
}


@override
int get hashCode => Object.hash(runtimeType,phase,selected,credentials,duration,message,didRefreshOnFailure,killSwitchEnabled,reconnecting,networkKind,downRate,upRate);

@override
String toString() {
  return 'SessionState(phase: $phase, selected: $selected, credentials: $credentials, duration: $duration, message: $message, didRefreshOnFailure: $didRefreshOnFailure, killSwitchEnabled: $killSwitchEnabled, reconnecting: $reconnecting, networkKind: $networkKind, downRate: $downRate, upRate: $upRate)';
}


}

/// @nodoc
abstract mixin class $SessionStateCopyWith<$Res>  {
  factory $SessionStateCopyWith(SessionState value, $Res Function(SessionState) _then) = _$SessionStateCopyWithImpl;
@useResult
$Res call({
 SessionPhase phase, VpnLocation? selected, VpnCredentials? credentials, String duration, String? message, bool didRefreshOnFailure, bool killSwitchEnabled, bool reconnecting, NetworkKind networkKind, String downRate, String upRate
});


$VpnLocationCopyWith<$Res>? get selected;$VpnCredentialsCopyWith<$Res>? get credentials;

}
/// @nodoc
class _$SessionStateCopyWithImpl<$Res>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._self, this._then);

  final SessionState _self;
  final $Res Function(SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? selected = freezed,Object? credentials = freezed,Object? duration = null,Object? message = freezed,Object? didRefreshOnFailure = null,Object? killSwitchEnabled = null,Object? reconnecting = null,Object? networkKind = null,Object? downRate = null,Object? upRate = null,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SessionPhase,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as VpnLocation?,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as VpnCredentials?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,didRefreshOnFailure: null == didRefreshOnFailure ? _self.didRefreshOnFailure : didRefreshOnFailure // ignore: cast_nullable_to_non_nullable
as bool,killSwitchEnabled: null == killSwitchEnabled ? _self.killSwitchEnabled : killSwitchEnabled // ignore: cast_nullable_to_non_nullable
as bool,reconnecting: null == reconnecting ? _self.reconnecting : reconnecting // ignore: cast_nullable_to_non_nullable
as bool,networkKind: null == networkKind ? _self.networkKind : networkKind // ignore: cast_nullable_to_non_nullable
as NetworkKind,downRate: null == downRate ? _self.downRate : downRate // ignore: cast_nullable_to_non_nullable
as String,upRate: null == upRate ? _self.upRate : upRate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnLocationCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $VpnLocationCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}/// Create a copy of SessionState
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


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionState value)  $default,){
final _that = this;
switch (_that) {
case _SessionState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionPhase phase,  VpnLocation? selected,  VpnCredentials? credentials,  String duration,  String? message,  bool didRefreshOnFailure,  bool killSwitchEnabled,  bool reconnecting,  NetworkKind networkKind,  String downRate,  String upRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.phase,_that.selected,_that.credentials,_that.duration,_that.message,_that.didRefreshOnFailure,_that.killSwitchEnabled,_that.reconnecting,_that.networkKind,_that.downRate,_that.upRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionPhase phase,  VpnLocation? selected,  VpnCredentials? credentials,  String duration,  String? message,  bool didRefreshOnFailure,  bool killSwitchEnabled,  bool reconnecting,  NetworkKind networkKind,  String downRate,  String upRate)  $default,) {final _that = this;
switch (_that) {
case _SessionState():
return $default(_that.phase,_that.selected,_that.credentials,_that.duration,_that.message,_that.didRefreshOnFailure,_that.killSwitchEnabled,_that.reconnecting,_that.networkKind,_that.downRate,_that.upRate);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionPhase phase,  VpnLocation? selected,  VpnCredentials? credentials,  String duration,  String? message,  bool didRefreshOnFailure,  bool killSwitchEnabled,  bool reconnecting,  NetworkKind networkKind,  String downRate,  String upRate)?  $default,) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.phase,_that.selected,_that.credentials,_that.duration,_that.message,_that.didRefreshOnFailure,_that.killSwitchEnabled,_that.reconnecting,_that.networkKind,_that.downRate,_that.upRate);case _:
  return null;

}
}

}

/// @nodoc


class _SessionState extends SessionState {
  const _SessionState({this.phase = SessionPhase.idle, this.selected, this.credentials, this.duration = '00:00:00', this.message, this.didRefreshOnFailure = false, this.killSwitchEnabled = true, this.reconnecting = false, this.networkKind = NetworkKind.other, this.downRate = '—', this.upRate = '—'}): super._();
  

@override@JsonKey() final  SessionPhase phase;
@override final  VpnLocation? selected;
@override final  VpnCredentials? credentials;
@override@JsonKey() final  String duration;
@override final  String? message;
@override@JsonKey() final  bool didRefreshOnFailure;
@override@JsonKey() final  bool killSwitchEnabled;
@override@JsonKey() final  bool reconnecting;
@override@JsonKey() final  NetworkKind networkKind;
@override@JsonKey() final  String downRate;
@override@JsonKey() final  String upRate;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStateCopyWith<_SessionState> get copyWith => __$SessionStateCopyWithImpl<_SessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.message, message) || other.message == message)&&(identical(other.didRefreshOnFailure, didRefreshOnFailure) || other.didRefreshOnFailure == didRefreshOnFailure)&&(identical(other.killSwitchEnabled, killSwitchEnabled) || other.killSwitchEnabled == killSwitchEnabled)&&(identical(other.reconnecting, reconnecting) || other.reconnecting == reconnecting)&&(identical(other.networkKind, networkKind) || other.networkKind == networkKind)&&(identical(other.downRate, downRate) || other.downRate == downRate)&&(identical(other.upRate, upRate) || other.upRate == upRate));
}


@override
int get hashCode => Object.hash(runtimeType,phase,selected,credentials,duration,message,didRefreshOnFailure,killSwitchEnabled,reconnecting,networkKind,downRate,upRate);

@override
String toString() {
  return 'SessionState(phase: $phase, selected: $selected, credentials: $credentials, duration: $duration, message: $message, didRefreshOnFailure: $didRefreshOnFailure, killSwitchEnabled: $killSwitchEnabled, reconnecting: $reconnecting, networkKind: $networkKind, downRate: $downRate, upRate: $upRate)';
}


}

/// @nodoc
abstract mixin class _$SessionStateCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory _$SessionStateCopyWith(_SessionState value, $Res Function(_SessionState) _then) = __$SessionStateCopyWithImpl;
@override @useResult
$Res call({
 SessionPhase phase, VpnLocation? selected, VpnCredentials? credentials, String duration, String? message, bool didRefreshOnFailure, bool killSwitchEnabled, bool reconnecting, NetworkKind networkKind, String downRate, String upRate
});


@override $VpnLocationCopyWith<$Res>? get selected;@override $VpnCredentialsCopyWith<$Res>? get credentials;

}
/// @nodoc
class __$SessionStateCopyWithImpl<$Res>
    implements _$SessionStateCopyWith<$Res> {
  __$SessionStateCopyWithImpl(this._self, this._then);

  final _SessionState _self;
  final $Res Function(_SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? selected = freezed,Object? credentials = freezed,Object? duration = null,Object? message = freezed,Object? didRefreshOnFailure = null,Object? killSwitchEnabled = null,Object? reconnecting = null,Object? networkKind = null,Object? downRate = null,Object? upRate = null,}) {
  return _then(_SessionState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SessionPhase,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as VpnLocation?,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as VpnCredentials?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,didRefreshOnFailure: null == didRefreshOnFailure ? _self.didRefreshOnFailure : didRefreshOnFailure // ignore: cast_nullable_to_non_nullable
as bool,killSwitchEnabled: null == killSwitchEnabled ? _self.killSwitchEnabled : killSwitchEnabled // ignore: cast_nullable_to_non_nullable
as bool,reconnecting: null == reconnecting ? _self.reconnecting : reconnecting // ignore: cast_nullable_to_non_nullable
as bool,networkKind: null == networkKind ? _self.networkKind : networkKind // ignore: cast_nullable_to_non_nullable
as NetworkKind,downRate: null == downRate ? _self.downRate : downRate // ignore: cast_nullable_to_non_nullable
as String,upRate: null == upRate ? _self.upRate : upRate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnLocationCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $VpnLocationCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}/// Create a copy of SessionState
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

// dart format on
