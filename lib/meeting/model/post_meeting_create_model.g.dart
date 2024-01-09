// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_meeting_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostMeetingCreateModel _$PostMeetingCreateModelFromJson(
        Map<String, dynamic> json) =>
    PostMeetingCreateModel(
      trainerId: json['trainerId'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$PostMeetingCreateModelToJson(
        PostMeetingCreateModel instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
    };
