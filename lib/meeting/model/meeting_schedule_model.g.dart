// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingScheduleModel _$MeetingScheduleModelFromJson(
        Map<String, dynamic> json) =>
    MeetingScheduleModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => MeetingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingScheduleModelToJson(
        MeetingScheduleModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

MeetingData _$MeetingDataFromJson(Map<String, dynamic> json) => MeetingData(
      startDate: json['startDate'] as String,
      meetings: (json['meetings'] as List<dynamic>)
          .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingDataToJson(MeetingData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate,
      'meetings': instance.meetings,
    };

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
      id: json['id'] as int,
      status: json['status'] as String,
      endTime: json['endTime'] as String,
      trainer: Trainer.fromJson(json['trainer'] as Map<String, dynamic>),
      startTime: json['startTime'] as String,
      userNickname: json['userNickname'] as String,
    );

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'endTime': instance.endTime,
      'trainer': instance.trainer,
      'startTime': instance.startTime,
      'userNickname': instance.userNickname,
    };
