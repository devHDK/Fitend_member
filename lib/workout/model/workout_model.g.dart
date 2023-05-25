// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutModel _$WorkoutModelFromJson(Map<String, dynamic> json) => WorkoutModel(
      workoutScheduleId: json['workoutScheduleId'] as int,
      startDate: json['startDate'] as String,
      workoutTitle: json['workoutTitle'] as String,
      workoutSubTitle: json['workoutSubTitle'] as String,
      targetMuscleTypes: (json['targetMuscleTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      workoutTotalTime: json['workoutTotalTime'] as String,
      isWorkoutComplete: json['isWorkoutComplete'] as bool,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutModelToJson(WorkoutModel instance) =>
    <String, dynamic>{
      'workoutScheduleId': instance.workoutScheduleId,
      'startDate': instance.startDate,
      'workoutTitle': instance.workoutTitle,
      'workoutSubTitle': instance.workoutSubTitle,
      'targetMuscleTypes': instance.targetMuscleTypes,
      'workoutTotalTime': instance.workoutTotalTime,
      'isWorkoutComplete': instance.isWorkoutComplete,
      'exercises': instance.exercises,
    };
