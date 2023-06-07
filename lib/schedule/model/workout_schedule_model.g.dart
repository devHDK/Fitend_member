// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutScheduleModel _$WorkoutScheduleModelFromJson(
        Map<String, dynamic> json) =>
    WorkoutScheduleModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WorkoutData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutScheduleModelToJson(
        WorkoutScheduleModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

WorkoutData _$WorkoutDataFromJson(Map<String, dynamic> json) => WorkoutData(
      startDate: DateTime.parse(json['startDate'] as String),
      workouts: (json['workouts'] as List<dynamic>?)
          ?.map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutDataToJson(WorkoutData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'workouts': instance.workouts,
    };

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      seq: json['seq'] as int,
      title: json['title'] as String,
      subTitle: json['subTitle'] as String,
      isComplete: json['isComplete'] as bool,
      isRecord: json['isRecord'] as bool,
      workoutScheduleId: json['workoutScheduleId'] as int,
      selected: json['selected'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'seq': instance.seq,
      'title': instance.title,
      'subTitle': instance.subTitle,
      'isComplete': instance.isComplete,
      'isRecord': instance.isRecord,
      'workoutScheduleId': instance.workoutScheduleId,
      'selected': instance.selected,
    };
