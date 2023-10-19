import 'package:fitend_member/thread/model/common/thread_workout_info_model.dart';
import 'package:fitend_member/workout/model/schedule_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_workout_record_model.g.dart';

@JsonSerializable()
class PostWorkoutRecordModel {
  final List<WorkoutRecordSimple> records;
  final ScheduleRecordsModel scheduleRecords;
  final ThreadWorkoutInfo? workoutInfo;

  PostWorkoutRecordModel({
    required this.records,
    required this.scheduleRecords,
    this.workoutInfo,
  });

  PostWorkoutRecordModel copyWith({
    List<WorkoutRecordSimple>? records,
    ScheduleRecordsModel? scheduleRecords,
    ThreadWorkoutInfo? workoutInfo,
  }) =>
      PostWorkoutRecordModel(
        records: records ?? this.records,
        scheduleRecords: scheduleRecords ?? this.scheduleRecords,
        workoutInfo: workoutInfo ?? this.workoutInfo,
      );

  factory PostWorkoutRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PostWorkoutRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostWorkoutRecordModelToJson(this);
}
