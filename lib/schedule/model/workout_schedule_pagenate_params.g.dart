// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule_pagenate_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchedulePagenateParams _$SchedulePagenateParamsFromJson(
        Map<String, dynamic> json) =>
    SchedulePagenateParams(
      startDate: DateTime.parse(json['startDate'] as String),
      interval: json['interval'] as int,
    );

Map<String, dynamic> _$SchedulePagenateParamsToJson(
        SchedulePagenateParams instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'interval': instance.interval,
    };
