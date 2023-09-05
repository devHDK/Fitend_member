import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_feedback_record_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class WorkoutFeedbackRecordModel {
  @HiveField(1)
  final DateTime startDate;
  @HiveField(2)
  final int? strengthIndex;
  @HiveField(3)
  final List<int>? issueIndexes;
  @HiveField(4)
  final String? contents;

  WorkoutFeedbackRecordModel({
    required this.startDate,
    this.strengthIndex,
    this.issueIndexes,
    this.contents,
  });

  WorkoutFeedbackRecordModel copyWith({
    DateTime? startDate,
    int? strengthIndex,
    List<int>? issueIndexes,
    String? contents,
  }) =>
      WorkoutFeedbackRecordModel(
        startDate: startDate ?? this.startDate,
        strengthIndex: strengthIndex ?? this.strengthIndex,
        issueIndexes: issueIndexes ?? this.issueIndexes,
        contents: contents ?? this.contents,
      );
  factory WorkoutFeedbackRecordModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFeedbackRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutFeedbackRecordModelToJson(this);
}
