import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_workout_record_model.g.dart';

@JsonSerializable()
class PostWorkoutRecordModel {
  final List<WorkoutRecordSimple> records;

  PostWorkoutRecordModel({
    required this.records,
  });

  PostWorkoutRecordModel copyWith({
    List<WorkoutRecordSimple>? records,
  }) =>
      PostWorkoutRecordModel(
        records: records ?? this.records,
      );

  factory PostWorkoutRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PostWorkoutRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostWorkoutRecordModelToJson(this);
}
