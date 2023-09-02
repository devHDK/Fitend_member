// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_process_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProcessModel _$WorkoutProcessModelFromJson(Map<String, dynamic> json) =>
    WorkoutProcessModel(
      exerciseIndex: json['exerciseIndex'] as int,
      maxExerciseIndex: json['maxExerciseIndex'] as int,
      setInfoCompleteList: (json['setInfoCompleteList'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      maxSetInfoList: (json['maxSetInfoList'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifiedExercises: (json['modifiedExercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      workoutFinished: json['workoutFinished'] as bool,
    );

Map<String, dynamic> _$WorkoutProcessModelToJson(
        WorkoutProcessModel instance) =>
    <String, dynamic>{
      'exerciseIndex': instance.exerciseIndex,
      'maxExerciseIndex': instance.maxExerciseIndex,
      'setInfoCompleteList': instance.setInfoCompleteList,
      'maxSetInfoList': instance.maxSetInfoList,
      'exercises': instance.exercises,
      'modifiedExercises': instance.modifiedExercises,
      'workoutFinished': instance.workoutFinished,
    };
