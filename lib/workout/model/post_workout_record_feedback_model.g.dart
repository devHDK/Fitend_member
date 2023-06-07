// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_workout_record_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWorkoutRecordFeedbackModel _$PostWorkoutRecordFeedbackModelFromJson(
        Map<String, dynamic> json) =>
    PostWorkoutRecordFeedbackModel(
      strengthIndex: json['strengthIndex'] as int,
      issueIndexes: (json['issueIndexes'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      contents: json['contents'] as String?,
    );

Map<String, dynamic> _$PostWorkoutRecordFeedbackModelToJson(
        PostWorkoutRecordFeedbackModel instance) =>
    <String, dynamic>{
      'strengthIndex': instance.strengthIndex,
      'issueIndexes': instance.issueIndexes,
      'contents': instance.contents,
    };
