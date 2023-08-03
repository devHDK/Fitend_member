// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_confirm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationConfirmResponse _$NotificationConfirmResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationConfirmResponse(
      isConfirm: json['isConfirm'] as bool,
    );

Map<String, dynamic> _$NotificationConfirmResponseToJson(
        NotificationConfirmResponse instance) =>
    <String, dynamic>{
      'isConfirm': instance.isConfirm,
    };

NotificationConfirmParams _$NotificationConfirmParamsFromJson(
        Map<String, dynamic> json) =>
    NotificationConfirmParams(
      start: json['start'] as int,
      perPage: json['perPage'] as int,
    );

Map<String, dynamic> _$NotificationConfirmParamsToJson(
        NotificationConfirmParams instance) =>
    <String, dynamic>{
      'start': instance.start,
      'perPage': instance.perPage,
    };
