// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule_pagenate_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSchedulePagenateParams _$WorkoutSchedulePagenateParamsFromJson(
        Map<String, dynamic> json) =>
    WorkoutSchedulePagenateParams(
      startDate: DateTime.parse(json['startDate'] as String),
      interval: json['interval'] as int,
    );

Map<String, dynamic> _$WorkoutSchedulePagenateParamsToJson(
        WorkoutSchedulePagenateParams instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'interval': instance.interval,
    };
