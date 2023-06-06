// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_workout_record_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWorkoutRecordFeedbackModel _$PostWorkoutRecordFeedbackModelFromJson(
        Map<String, dynamic> json) =>
    PostWorkoutRecordFeedbackModel(
      strengthIndex: json['strengthIndex'] as int,
      issueIndex: json['issueIndex'] as int,
      contents: json['contents'] as String,
    );

Map<String, dynamic> _$PostWorkoutRecordFeedbackModelToJson(
        PostWorkoutRecordFeedbackModel instance) =>
    <String, dynamic>{
      'strengthIndex': instance.strengthIndex,
      'issueIndex': instance.issueIndex,
      'contents': instance.contents,
    };
