// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_workout_schedule_date_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutWorkoutScheduleModel _$PutWorkoutScheduleModelFromJson(
        Map<String, dynamic> json) =>
    PutWorkoutScheduleModel(
      startDate: json['startDate'] as String,
      seq: json['seq'] as int,
    );

Map<String, dynamic> _$PutWorkoutScheduleModelToJson(
        PutWorkoutScheduleModel instance) =>
    <String, dynamic>{
      'startDate': instance.startDate,
      'seq': instance.seq,
    };
