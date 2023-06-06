import 'package:json_annotation/json_annotation.dart';

part 'post_workout_record_feedback_model.g.dart';

@JsonSerializable()
class PostWorkoutRecordFeedbackModel {
  final int strengthIndex;
  final int issueIndex;
  final String contents;

  PostWorkoutRecordFeedbackModel({
    required this.strengthIndex,
    required this.issueIndex,
    required this.contents,
  });

  PostWorkoutRecordFeedbackModel copyWith({
    int? strengthIndex,
    int? issueIndex,
    String? contents,
  }) =>
      PostWorkoutRecordFeedbackModel(
        strengthIndex: strengthIndex ?? this.strengthIndex,
        issueIndex: issueIndex ?? this.issueIndex,
        contents: contents ?? this.contents,
      );

  factory PostWorkoutRecordFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$PostWorkoutRecordFeedbackModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostWorkoutRecordFeedbackModelToJson(this);
}
