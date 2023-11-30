// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutHistoryModel _$WorkoutHistoryModelFromJson(Map<String, dynamic> json) =>
    WorkoutHistoryModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => HistoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$WorkoutHistoryModelToJson(
        WorkoutHistoryModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
    };

HistoryData _$HistoryDataFromJson(Map<String, dynamic> json) => HistoryData(
      startDate: json['startDate'] as String,
      workoutRecordId: json['workoutRecordId'] as int,
      workoutPlanId: json['workoutPlanId'] as int,
      exerciseName: json['exerciseName'] as String,
      setInfo: (json['setInfo'] as List<dynamic>)
          .map((e) => SetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HistoryDataToJson(HistoryData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate,
      'workoutRecordId': instance.workoutRecordId,
      'workoutPlanId': instance.workoutPlanId,
      'exerciseName': instance.exerciseName,
      'setInfo': instance.setInfo,
    };

SetInfo _$SetInfoFromJson(Map<String, dynamic> json) => SetInfo(
      reps: json['reps'] as int,
      index: json['index'] as int,
      weight: json['weight'] as int,
      seconds: json['seconds'] as int,
    );

Map<String, dynamic> _$SetInfoToJson(SetInfo instance) => <String, dynamic>{
      'reps': instance.reps,
      'index': instance.index,
      'weight': instance.weight,
      'seconds': instance.seconds,
    };
