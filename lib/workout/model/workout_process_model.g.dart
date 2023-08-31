// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_process_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProcessModel _$WorkoutProcessModelFromJson(Map<String, dynamic> json) =>
    WorkoutProcessModel(
      recentWorkoutIndex: json['recentWorkoutIndex'] as int,
      recentSetIndex: json['recentSetIndex'] as int,
      maxExerciseIndex: json['maxExerciseIndex'] as int,
      setInfoCompleteList: (json['setInfoCompleteList'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      maxSetInfoList: (json['maxSetInfoList'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      workout: Workout.fromJson(json['workout'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkoutProcessModelToJson(
        WorkoutProcessModel instance) =>
    <String, dynamic>{
      'recentWorkoutIndex': instance.recentWorkoutIndex,
      'recentSetIndex': instance.recentSetIndex,
      'maxExerciseIndex': instance.maxExerciseIndex,
      'setInfoCompleteList': instance.setInfoCompleteList,
      'maxSetInfoList': instance.maxSetInfoList,
      'workout': instance.workout,
    };
