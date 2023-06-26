import 'package:json_annotation/json_annotation.dart';

part 'post_workout_record_feedback_model.g.dart';

@JsonSerializable()
class PostWorkoutRecordFeedbackModel {
  final int strengthIndex;
  final List<int>? issueIndexes;
  final String? contents;

  PostWorkoutRecordFeedbackModel({
    required this.strengthIndex,
    required this.issueIndexes,
    required this.contents,
  });

  PostWorkoutRecordFeedbackModel copyWith({
    int? strengthIndex,
    List<int>? issueIndexes,
    String? contents,
  }) =>
      PostWorkoutRecordFeedbackModel(
        strengthIndex: strengthIndex ?? this.strengthIndex,
        issueIndexes: issueIndexes ?? this.issueIndexes,
        contents: contents ?? this.contents,
      );
  factory PostWorkoutRecordFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$PostWorkoutRecordFeedbackModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostWorkoutRecordFeedbackModelToJson(this);
}
