// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vpn_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VpnLocation _$VpnLocationFromJson(Map<String, dynamic> json) => _VpnLocation(
  id: jsonInt(json['id']),
  country: jsonString(json['country']),
  region: jsonString(json['region']),
  city: jsonString(json['city']),
  title: jsonString(json['title']),
  flagUrl: jsonString(json['flagUrl']),
  config: jsonString(json['config']),
  networkFlagUrl: jsonString(json['networkFlagUrl']),
  isPremium: jsonBool(json['isPremium']),
);

Map<String, dynamic> _$VpnLocationToJson(_VpnLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'country': instance.country,
      'region': instance.region,
      'city': instance.city,
      'title': instance.title,
      'flagUrl': instance.flagUrl,
      'config': instance.config,
      'networkFlagUrl': instance.networkFlagUrl,
      'isPremium': instance.isPremium,
    };

_VpnCredentials _$VpnCredentialsFromJson(Map<String, dynamic> json) =>
    _VpnCredentials(
      username: jsonString(json['username']),
      password: jsonString(json['password']),
      fastServerIndex: jsonInt(json['fastServerIndex']),
      connectionTimeoutSeconds: json['connectionTimeoutSeconds'] == null
          ? 30
          : jsonTimeout(json['connectionTimeoutSeconds']),
    );

Map<String, dynamic> _$VpnCredentialsToJson(_VpnCredentials instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'fastServerIndex': instance.fastServerIndex,
      'connectionTimeoutSeconds': instance.connectionTimeoutSeconds,
    };
