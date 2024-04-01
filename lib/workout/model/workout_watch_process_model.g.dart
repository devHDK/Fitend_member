// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_watch_process_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutWatchProcessModel _$WorkoutWatchProcessModelFromJson(
        Map<String, dynamic> json) =>
    WorkoutWatchProcessModel(
      command: json['command'] as String,
      watchModel: WorkoutWatchModel.fromJson(
          json['watchModel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkoutWatchProcessModelToJson(
        WorkoutWatchProcessModel instance) =>
    <String, dynamic>{
      'command': instance.command,
      'watchModel': instance.watchModel.toJson(),
    };

WorkoutWatchModel _$WorkoutWatchModelFromJson(Map<String, dynamic> json) =>
    WorkoutWatchModel(
      exerciseIndex: json['exerciseIndex'] as int,
      maxExerciseIndex: json['maxExerciseIndex'] as int,
      setInfoCompleteList: (json['setInfoCompleteList'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      maxSetInfoList: (json['maxSetInfoList'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
      workoutFinished: json['workoutFinished'] as bool,
      groupCounts: (json['groupCounts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as int),
      ),
      totalTime: json['totalTime'] as int,
      isQuitting: json['isQuitting'] as bool,
    );

Map<String, dynamic> _$WorkoutWatchModelToJson(WorkoutWatchModel instance) =>
    <String, dynamic>{
      'exerciseIndex': instance.exerciseIndex,
      'maxExerciseIndex': instance.maxExerciseIndex,
      'setInfoCompleteList': instance.setInfoCompleteList,
      'maxSetInfoList': instance.maxSetInfoList,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'workoutFinished': instance.workoutFinished,
      'groupCounts':
          instance.groupCounts.map((k, e) => MapEntry(k.toString(), e)),
      'totalTime': instance.totalTime,
      'isQuitting': instance.isQuitting,
    };
