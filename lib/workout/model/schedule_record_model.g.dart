// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleRecordsModel _$ScheduleRecordsModelFromJson(
        Map<String, dynamic> json) =>
    ScheduleRecordsModel(
      workoutScheduleId: json['workoutScheduleId'] as int?,
      heartRates:
          (json['heartRates'] as List<dynamic>?)?.map((e) => e as int).toList(),
      workoutDuration: json['workoutDuration'] as int?,
    );

Map<String, dynamic> _$ScheduleRecordsModelToJson(
        ScheduleRecordsModel instance) =>
    <String, dynamic>{
      'workoutScheduleId': instance.workoutScheduleId,
      'heartRates': instance.heartRates,
      'workoutDuration': instance.workoutDuration,
    };
