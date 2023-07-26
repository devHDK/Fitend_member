// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
    };

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      id: json['id'] as int,
      type: json['type'] as String,
      contents: json['contents'] as String,
      info: json['info'] == null
          ? null
          : Info.fromJson(json['info'] as Map<String, dynamic>),
      isConfirm: json['isConfirm'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'contents': instance.contents,
      'info': instance.info,
      'isConfirm': instance.isConfirm,
      'createdAt': instance.createdAt,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      workoutScheduleId: json['workoutScheduleId'] as int?,
      reservationId: json['reservationId'] as int?,
    );

Map<String, dynamic> _$InfoToJson(Info instance) => <String, dynamic>{
      'workoutScheduleId': instance.workoutScheduleId,
      'reservationId': instance.reservationId,
    };
