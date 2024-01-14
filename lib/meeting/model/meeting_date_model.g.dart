// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_date_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingDateModel _$MeetingDateModelFromJson(Map<String, dynamic> json) =>
    MeetingDateModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ScheduleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingDateModelToJson(MeetingDateModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

ScheduleData _$ScheduleDataFromJson(Map<String, dynamic> json) => ScheduleData(
      startDate: DateTime.parse(json['startDate'] as String),
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => TrainerSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleDataToJson(ScheduleData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'schedules': instance.schedules,
    };

TrainerSchedule _$TrainerScheduleFromJson(Map<String, dynamic> json) =>
    TrainerSchedule(
      endTime: DataUtils.dateTimeToLocal(json['endTime'] as String),
      startTime: DataUtils.dateTimeToLocal(json['startTime'] as String),
      type: json['type'] as String,
      isAvail: json['isAvail'] as bool?,
    );

Map<String, dynamic> _$TrainerScheduleToJson(TrainerSchedule instance) =>
    <String, dynamic>{
      'endTime': instance.endTime.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
      'type': instance.type,
      'isAvail': instance.isAvail,
    };
