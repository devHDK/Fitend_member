// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_schedule_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerScheduleList _$TrainerScheduleListFromJson(Map<String, dynamic> json) =>
    TrainerScheduleList(
      data: (json['data'] as List<dynamic>)
          .map((e) => TrainerSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrainerScheduleListToJson(
        TrainerScheduleList instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

TrainerSchedule _$TrainerScheduleFromJson(Map<String, dynamic> json) =>
    TrainerSchedule(
      startDate: DateTime.parse(json['startDate'] as String),
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => TrainerScheduleDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrainerScheduleToJson(TrainerSchedule instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'schedules': instance.schedules,
    };

TrainerScheduleDetail _$TrainerScheduleDetailFromJson(
        Map<String, dynamic> json) =>
    TrainerScheduleDetail(
      type: json['type'] as String,
      endTime: DateTime.parse(json['endTime'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
    );

Map<String, dynamic> _$TrainerScheduleDetailToJson(
        TrainerScheduleDetail instance) =>
    <String, dynamic>{
      'type': instance.type,
      'endTime': instance.endTime.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
    };
