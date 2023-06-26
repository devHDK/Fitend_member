import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_workout_record_model.g.dart';

@JsonSerializable()
class PostWorkoutRecordModel {
  final List<WorkoutRecordModel> records;

  PostWorkoutRecordModel({
    required this.records,
  });

  PostWorkoutRecordModel copyWith({
    List<WorkoutRecordModel>? records,
  }) =>
      PostWorkoutRecordModel(
        records: records ?? this.records,
      );

  factory PostWorkoutRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PostWorkoutRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostWorkoutRecordModelToJson(this);
}
