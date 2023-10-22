// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificatiion_main_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMainModel _$NotificationMainModelFromJson(
        Map<String, dynamic> json) =>
    NotificationMainModel(
      isConfirmed: json['isConfirmed'] as bool,
      threadBadgeCount: json['threadBadgeCount'] as int,
    );

Map<String, dynamic> _$NotificationMainModelToJson(
        NotificationMainModel instance) =>
    <String, dynamic>{
      'isConfirmed': instance.isConfirmed,
      'threadBadgeCount': instance.threadBadgeCount,
    };
