// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_workout_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadWorkoutInfo _$ThreadWorkoutInfoFromJson(Map<String, dynamic> json) =>
    ThreadWorkoutInfo(
      trainerId: json['trainerId'] as int?,
      workoutScheduleId: json['workoutScheduleId'] as int,
      targetMuscleIds: (json['targetMuscleIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      title: json['title'] as String,
      subTitle: json['subTitle'] as String,
      workoutDuration: json['workoutDuration'] as int?,
      totalSet: json['totalSet'] as int,
      heartRate: json['heartRate'] as int?,
      calories: json['calories'] as int?,
    );

Map<String, dynamic> _$ThreadWorkoutInfoToJson(ThreadWorkoutInfo instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'workoutScheduleId': instance.workoutScheduleId,
      'targetMuscleIds': instance.targetMuscleIds,
      'title': instance.title,
      'subTitle': instance.subTitle,
      'workoutDuration': instance.workoutDuration,
      'totalSet': instance.totalSet,
      'heartRate': instance.heartRate,
      'calories': instance.calories,
    };
