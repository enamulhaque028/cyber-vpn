// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vpn_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VpnLocation {

@JsonKey(fromJson: jsonInt) int get id;@JsonKey(fromJson: jsonString) String get country;@JsonKey(fromJson: jsonString) String get region;@JsonKey(fromJson: jsonString) String get city;@JsonKey(fromJson: jsonString) String get title;@JsonKey(fromJson: jsonString) String get flagUrl;@JsonKey(fromJson: jsonString) String get config;@JsonKey(fromJson: jsonString) String get networkFlagUrl;@JsonKey(fromJson: jsonBool) bool get isPremium;
/// Create a copy of VpnLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnLocationCopyWith<VpnLocation> get copyWith => _$VpnLocationCopyWithImpl<VpnLocation>(this as VpnLocation, _$identity);

  /// Serializes this VpnLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.country, country) || other.country == country)&&(identical(other.region, region) || other.region == region)&&(identical(other.city, city) || other.city == city)&&(identical(other.title, title) || other.title == title)&&(identical(other.flagUrl, flagUrl) || other.flagUrl == flagUrl)&&(identical(other.config, config) || other.config == config)&&(identical(other.networkFlagUrl, networkFlagUrl) || other.networkFlagUrl == networkFlagUrl)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,country,region,city,title,flagUrl,config,networkFlagUrl,isPremium);

@override
String toString() {
  return 'VpnLocation(id: $id, country: $country, region: $region, city: $city, title: $title, flagUrl: $flagUrl, config: $config, networkFlagUrl: $networkFlagUrl, isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class $VpnLocationCopyWith<$Res>  {
  factory $VpnLocationCopyWith(VpnLocation value, $Res Function(VpnLocation) _then) = _$VpnLocationCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: jsonInt) int id,@JsonKey(fromJson: jsonString) String country,@JsonKey(fromJson: jsonString) String region,@JsonKey(fromJson: jsonString) String city,@JsonKey(fromJson: jsonString) String title,@JsonKey(fromJson: jsonString) String flagUrl,@JsonKey(fromJson: jsonString) String config,@JsonKey(fromJson: jsonString) String networkFlagUrl,@JsonKey(fromJson: jsonBool) bool isPremium
});




}
/// @nodoc
class _$VpnLocationCopyWithImpl<$Res>
    implements $VpnLocationCopyWith<$Res> {
  _$VpnLocationCopyWithImpl(this._self, this._then);

  final VpnLocation _self;
  final $Res Function(VpnLocation) _then;

/// Create a copy of VpnLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? country = null,Object? region = null,Object? city = null,Object? title = null,Object? flagUrl = null,Object? config = null,Object? networkFlagUrl = null,Object? isPremium = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,flagUrl: null == flagUrl ? _self.flagUrl : flagUrl // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as String,networkFlagUrl: null == networkFlagUrl ? _self.networkFlagUrl : networkFlagUrl // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VpnLocation].
extension VpnLocationPatterns on VpnLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnLocation value)  $default,){
final _that = this;
switch (_that) {
case _VpnLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnLocation value)?  $default,){
final _that = this;
switch (_that) {
case _VpnLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: jsonInt)  int id, @JsonKey(fromJson: jsonString)  String country, @JsonKey(fromJson: jsonString)  String region, @JsonKey(fromJson: jsonString)  String city, @JsonKey(fromJson: jsonString)  String title, @JsonKey(fromJson: jsonString)  String flagUrl, @JsonKey(fromJson: jsonString)  String config, @JsonKey(fromJson: jsonString)  String networkFlagUrl, @JsonKey(fromJson: jsonBool)  bool isPremium)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnLocation() when $default != null:
return $default(_that.id,_that.country,_that.region,_that.city,_that.title,_that.flagUrl,_that.config,_that.networkFlagUrl,_that.isPremium);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: jsonInt)  int id, @JsonKey(fromJson: jsonString)  String country, @JsonKey(fromJson: jsonString)  String region, @JsonKey(fromJson: jsonString)  String city, @JsonKey(fromJson: jsonString)  String title, @JsonKey(fromJson: jsonString)  String flagUrl, @JsonKey(fromJson: jsonString)  String config, @JsonKey(fromJson: jsonString)  String networkFlagUrl, @JsonKey(fromJson: jsonBool)  bool isPremium)  $default,) {final _that = this;
switch (_that) {
case _VpnLocation():
return $default(_that.id,_that.country,_that.region,_that.city,_that.title,_that.flagUrl,_that.config,_that.networkFlagUrl,_that.isPremium);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: jsonInt)  int id, @JsonKey(fromJson: jsonString)  String country, @JsonKey(fromJson: jsonString)  String region, @JsonKey(fromJson: jsonString)  String city, @JsonKey(fromJson: jsonString)  String title, @JsonKey(fromJson: jsonString)  String flagUrl, @JsonKey(fromJson: jsonString)  String config, @JsonKey(fromJson: jsonString)  String networkFlagUrl, @JsonKey(fromJson: jsonBool)  bool isPremium)?  $default,) {final _that = this;
switch (_that) {
case _VpnLocation() when $default != null:
return $default(_that.id,_that.country,_that.region,_that.city,_that.title,_that.flagUrl,_that.config,_that.networkFlagUrl,_that.isPremium);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnLocation extends VpnLocation {
  const _VpnLocation({@JsonKey(fromJson: jsonInt) required this.id, @JsonKey(fromJson: jsonString) required this.country, @JsonKey(fromJson: jsonString) required this.region, @JsonKey(fromJson: jsonString) required this.city, @JsonKey(fromJson: jsonString) required this.title, @JsonKey(fromJson: jsonString) required this.flagUrl, @JsonKey(fromJson: jsonString) required this.config, @JsonKey(fromJson: jsonString) required this.networkFlagUrl, @JsonKey(fromJson: jsonBool) required this.isPremium}): super._();
  factory _VpnLocation.fromJson(Map<String, dynamic> json) => _$VpnLocationFromJson(json);

@override@JsonKey(fromJson: jsonInt) final  int id;
@override@JsonKey(fromJson: jsonString) final  String country;
@override@JsonKey(fromJson: jsonString) final  String region;
@override@JsonKey(fromJson: jsonString) final  String city;
@override@JsonKey(fromJson: jsonString) final  String title;
@override@JsonKey(fromJson: jsonString) final  String flagUrl;
@override@JsonKey(fromJson: jsonString) final  String config;
@override@JsonKey(fromJson: jsonString) final  String networkFlagUrl;
@override@JsonKey(fromJson: jsonBool) final  bool isPremium;

/// Create a copy of VpnLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnLocationCopyWith<_VpnLocation> get copyWith => __$VpnLocationCopyWithImpl<_VpnLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.country, country) || other.country == country)&&(identical(other.region, region) || other.region == region)&&(identical(other.city, city) || other.city == city)&&(identical(other.title, title) || other.title == title)&&(identical(other.flagUrl, flagUrl) || other.flagUrl == flagUrl)&&(identical(other.config, config) || other.config == config)&&(identical(other.networkFlagUrl, networkFlagUrl) || other.networkFlagUrl == networkFlagUrl)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,country,region,city,title,flagUrl,config,networkFlagUrl,isPremium);

@override
String toString() {
  return 'VpnLocation(id: $id, country: $country, region: $region, city: $city, title: $title, flagUrl: $flagUrl, config: $config, networkFlagUrl: $networkFlagUrl, isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class _$VpnLocationCopyWith<$Res> implements $VpnLocationCopyWith<$Res> {
  factory _$VpnLocationCopyWith(_VpnLocation value, $Res Function(_VpnLocation) _then) = __$VpnLocationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: jsonInt) int id,@JsonKey(fromJson: jsonString) String country,@JsonKey(fromJson: jsonString) String region,@JsonKey(fromJson: jsonString) String city,@JsonKey(fromJson: jsonString) String title,@JsonKey(fromJson: jsonString) String flagUrl,@JsonKey(fromJson: jsonString) String config,@JsonKey(fromJson: jsonString) String networkFlagUrl,@JsonKey(fromJson: jsonBool) bool isPremium
});




}
/// @nodoc
class __$VpnLocationCopyWithImpl<$Res>
    implements _$VpnLocationCopyWith<$Res> {
  __$VpnLocationCopyWithImpl(this._self, this._then);

  final _VpnLocation _self;
  final $Res Function(_VpnLocation) _then;

/// Create a copy of VpnLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? country = null,Object? region = null,Object? city = null,Object? title = null,Object? flagUrl = null,Object? config = null,Object? networkFlagUrl = null,Object? isPremium = null,}) {
  return _then(_VpnLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,flagUrl: null == flagUrl ? _self.flagUrl : flagUrl // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as String,networkFlagUrl: null == networkFlagUrl ? _self.networkFlagUrl : networkFlagUrl // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$VpnCredentials {

@JsonKey(fromJson: jsonString) String get username;@JsonKey(fromJson: jsonString) String get password;@JsonKey(fromJson: jsonInt) int get fastServerIndex;@JsonKey(fromJson: jsonTimeout) int get connectionTimeoutSeconds;
/// Create a copy of VpnCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnCredentialsCopyWith<VpnCredentials> get copyWith => _$VpnCredentialsCopyWithImpl<VpnCredentials>(this as VpnCredentials, _$identity);

  /// Serializes this VpnCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnCredentials&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.fastServerIndex, fastServerIndex) || other.fastServerIndex == fastServerIndex)&&(identical(other.connectionTimeoutSeconds, connectionTimeoutSeconds) || other.connectionTimeoutSeconds == connectionTimeoutSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password,fastServerIndex,connectionTimeoutSeconds);

@override
String toString() {
  return 'VpnCredentials(username: $username, password: $password, fastServerIndex: $fastServerIndex, connectionTimeoutSeconds: $connectionTimeoutSeconds)';
}


}

/// @nodoc
abstract mixin class $VpnCredentialsCopyWith<$Res>  {
  factory $VpnCredentialsCopyWith(VpnCredentials value, $Res Function(VpnCredentials) _then) = _$VpnCredentialsCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: jsonString) String username,@JsonKey(fromJson: jsonString) String password,@JsonKey(fromJson: jsonInt) int fastServerIndex,@JsonKey(fromJson: jsonTimeout) int connectionTimeoutSeconds
});




}
/// @nodoc
class _$VpnCredentialsCopyWithImpl<$Res>
    implements $VpnCredentialsCopyWith<$Res> {
  _$VpnCredentialsCopyWithImpl(this._self, this._then);

  final VpnCredentials _self;
  final $Res Function(VpnCredentials) _then;

/// Create a copy of VpnCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? fastServerIndex = null,Object? connectionTimeoutSeconds = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fastServerIndex: null == fastServerIndex ? _self.fastServerIndex : fastServerIndex // ignore: cast_nullable_to_non_nullable
as int,connectionTimeoutSeconds: null == connectionTimeoutSeconds ? _self.connectionTimeoutSeconds : connectionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VpnCredentials].
extension VpnCredentialsPatterns on VpnCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnCredentials value)  $default,){
final _that = this;
switch (_that) {
case _VpnCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _VpnCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: jsonString)  String username, @JsonKey(fromJson: jsonString)  String password, @JsonKey(fromJson: jsonInt)  int fastServerIndex, @JsonKey(fromJson: jsonTimeout)  int connectionTimeoutSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnCredentials() when $default != null:
return $default(_that.username,_that.password,_that.fastServerIndex,_that.connectionTimeoutSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: jsonString)  String username, @JsonKey(fromJson: jsonString)  String password, @JsonKey(fromJson: jsonInt)  int fastServerIndex, @JsonKey(fromJson: jsonTimeout)  int connectionTimeoutSeconds)  $default,) {final _that = this;
switch (_that) {
case _VpnCredentials():
return $default(_that.username,_that.password,_that.fastServerIndex,_that.connectionTimeoutSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: jsonString)  String username, @JsonKey(fromJson: jsonString)  String password, @JsonKey(fromJson: jsonInt)  int fastServerIndex, @JsonKey(fromJson: jsonTimeout)  int connectionTimeoutSeconds)?  $default,) {final _that = this;
switch (_that) {
case _VpnCredentials() when $default != null:
return $default(_that.username,_that.password,_that.fastServerIndex,_that.connectionTimeoutSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnCredentials implements VpnCredentials {
  const _VpnCredentials({@JsonKey(fromJson: jsonString) required this.username, @JsonKey(fromJson: jsonString) required this.password, @JsonKey(fromJson: jsonInt) required this.fastServerIndex, @JsonKey(fromJson: jsonTimeout) this.connectionTimeoutSeconds = 30});
  factory _VpnCredentials.fromJson(Map<String, dynamic> json) => _$VpnCredentialsFromJson(json);

@override@JsonKey(fromJson: jsonString) final  String username;
@override@JsonKey(fromJson: jsonString) final  String password;
@override@JsonKey(fromJson: jsonInt) final  int fastServerIndex;
@override@JsonKey(fromJson: jsonTimeout) final  int connectionTimeoutSeconds;

/// Create a copy of VpnCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnCredentialsCopyWith<_VpnCredentials> get copyWith => __$VpnCredentialsCopyWithImpl<_VpnCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnCredentials&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.fastServerIndex, fastServerIndex) || other.fastServerIndex == fastServerIndex)&&(identical(other.connectionTimeoutSeconds, connectionTimeoutSeconds) || other.connectionTimeoutSeconds == connectionTimeoutSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password,fastServerIndex,connectionTimeoutSeconds);

@override
String toString() {
  return 'VpnCredentials(username: $username, password: $password, fastServerIndex: $fastServerIndex, connectionTimeoutSeconds: $connectionTimeoutSeconds)';
}


}

/// @nodoc
abstract mixin class _$VpnCredentialsCopyWith<$Res> implements $VpnCredentialsCopyWith<$Res> {
  factory _$VpnCredentialsCopyWith(_VpnCredentials value, $Res Function(_VpnCredentials) _then) = __$VpnCredentialsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: jsonString) String username,@JsonKey(fromJson: jsonString) String password,@JsonKey(fromJson: jsonInt) int fastServerIndex,@JsonKey(fromJson: jsonTimeout) int connectionTimeoutSeconds
});




}
/// @nodoc
class __$VpnCredentialsCopyWithImpl<$Res>
    implements _$VpnCredentialsCopyWith<$Res> {
  __$VpnCredentialsCopyWithImpl(this._self, this._then);

  final _VpnCredentials _self;
  final $Res Function(_VpnCredentials) _then;

/// Create a copy of VpnCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? fastServerIndex = null,Object? connectionTimeoutSeconds = null,}) {
  return _then(_VpnCredentials(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fastServerIndex: null == fastServerIndex ? _self.fastServerIndex : fastServerIndex // ignore: cast_nullable_to_non_nullable
as int,connectionTimeoutSeconds: null == connectionTimeoutSeconds ? _self.connectionTimeoutSeconds : connectionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
