// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingScheduleModel _$MeetingScheduleModelFromJson(
        Map<String, dynamic> json) =>
    MeetingScheduleModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => MeetingScheduleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingScheduleModelToJson(
        MeetingScheduleModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

MeetingScheduleData _$MeetingScheduleDataFromJson(Map<String, dynamic> json) =>
    MeetingScheduleData(
      startDate: DateTime.parse(json['startDate'] as String),
      meetings: (json['meetings'] as List<dynamic>)
          .map((e) => MeetingSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingScheduleDataToJson(
        MeetingScheduleData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'meetings': instance.meetings,
    };

MeetingSchedule _$MeetingScheduleFromJson(Map<String, dynamic> json) =>
    MeetingSchedule(
      id: json['id'] as int,
      status: json['status'] as String,
      endTime: DataUtils.dateTimeToLocal(json['endTime'] as String),
      trainer: ThreadTrainer.fromJson(json['trainer'] as Map<String, dynamic>),
      meetingLink: json['meetingLink'] as String,
      startTime: DataUtils.dateTimeToLocal(json['startTime'] as String),
      userNickname: json['userNickname'] as String,
      selected: json['selected'] as bool? ?? false,
    );

Map<String, dynamic> _$MeetingScheduleToJson(MeetingSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'endTime': instance.endTime.toIso8601String(),
      'meetingLink': instance.meetingLink,
      'trainer': instance.trainer,
      'startTime': instance.startTime.toIso8601String(),
      'userNickname': instance.userNickname,
      'selected': instance.selected,
    };
