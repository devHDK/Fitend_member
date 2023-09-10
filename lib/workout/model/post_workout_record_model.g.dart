// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_workout_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWorkoutRecordModel _$PostWorkoutRecordModelFromJson(
        Map<String, dynamic> json) =>
    PostWorkoutRecordModel(
      records: (json['records'] as List<dynamic>)
          .map((e) => WorkoutRecordSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
      scheduleRecords: ScheduleRecordsModel.fromJson(
          json['scheduleRecords'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostWorkoutRecordModelToJson(
        PostWorkoutRecordModel instance) =>
    <String, dynamic>{
      'records': instance.records,
      'scheduleRecords': instance.scheduleRecords,
    };
