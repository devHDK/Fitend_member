// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutScheduleModel _$WorkoutScheduleModelFromJson(
        Map<String, dynamic> json) =>
    WorkoutScheduleModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutScheduleModelToJson(
        WorkoutScheduleModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
      startDate: DateTime.parse(json['startDate'] as String),
      workouts: (json['workouts'] as List<dynamic>)
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'workouts': instance.workouts,
    };

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      seq: json['seq'] as int,
      title: json['title'] as String,
      subTitle: json['subTitle'] as String,
      isComplete: json['isComplete'] as bool,
      workoutScheduleId: json['workoutScheduleId'] as int,
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'seq': instance.seq,
      'title': instance.title,
      'subTitle': instance.subTitle,
      'isComplete': instance.isComplete,
      'workoutScheduleId': instance.workoutScheduleId,
    };
