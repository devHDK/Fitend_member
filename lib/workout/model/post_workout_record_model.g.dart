// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_workout_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWorkoutRecordModel _$PostWorkoutRecordModelFromJson(
        Map<String, dynamic> json) =>
    PostWorkoutRecordModel(
      records: (json['records'] as List<dynamic>)
          .map((e) => WorkoutRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PostWorkoutRecordModelToJson(
        PostWorkoutRecordModel instance) =>
    <String, dynamic>{
      'records': instance.records,
    };
