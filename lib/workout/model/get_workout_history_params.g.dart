// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_workout_history_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetWorkoutHistoryParams _$GetWorkoutHistoryParamsFromJson(
        Map<String, dynamic> json) =>
    GetWorkoutHistoryParams(
      workoutPlanId: json['workoutPlanId'] as int,
      start: json['start'] as int,
      perPage: json['perPage'] as int,
    );

Map<String, dynamic> _$GetWorkoutHistoryParamsToJson(
        GetWorkoutHistoryParams instance) =>
    <String, dynamic>{
      'workoutPlanId': instance.workoutPlanId,
      'start': instance.start,
      'perPage': instance.perPage,
    };
