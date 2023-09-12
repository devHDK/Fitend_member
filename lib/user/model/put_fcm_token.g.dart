// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_fcm_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutFcmToken _$PutFcmTokenFromJson(Map<String, dynamic> json) => PutFcmToken(
      deviceId: json['deviceId'] as String,
      token: json['token'] as String,
      platform: json['platform'] as String,
    );

Map<String, dynamic> _$PutFcmTokenToJson(PutFcmToken instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'token': instance.token,
      'platform': instance.platform,
    };
