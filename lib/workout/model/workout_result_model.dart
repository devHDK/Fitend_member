import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_result_model.g.dart';

abstract class WorkoutResultModelBase {}

class WorkoutResultModelLoading extends WorkoutResultModelBase {}

class WorkoutResultModelError extends WorkoutResultModelBase {
  final String message;

  WorkoutResultModelError({required this.message});
}

@JsonSerializable()
class WorkoutResultModel extends WorkoutResultModelBase {
  final String startDate;
  final int strengthIndex;
  final List<int>? issueIndexes;
  final String? contents;
  final List<WorkoutRecord> workoutRecords;

  WorkoutResultModel({
    required this.startDate,
    required this.strengthIndex,
    this.issueIndexes,
    this.contents,
    required this.workoutRecords,
  });

  WorkoutResultModel copyWith({
    String? startDate,
    int? strengthIndex,
    List<int>? issueIndexes,
    String? contents,
    List<WorkoutRecord>? workoutRecords,
  }) =>
      WorkoutResultModel(
        startDate: startDate ?? this.startDate,
        strengthIndex: strengthIndex ?? this.strengthIndex,
        issueIndexes: issueIndexes ?? this.issueIndexes,
        contents: contents ?? this.contents,
        workoutRecords: workoutRecords ?? this.workoutRecords,
      );

  factory WorkoutResultModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutResultModelToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 3)
class WorkoutRecord {
  @HiveField(1)
  final String exerciseName;
  @HiveField(2)
  final List<String> targetMuscles;
  @HiveField(3)
  final int trackingFieldId;
  @HiveField(4)
  final int workoutPlanId;
  @HiveField(5)
  final List<SetInfo> setInfo;

  WorkoutRecord({
    required this.exerciseName,
    required this.targetMuscles,
    required this.trackingFieldId,
    required this.workoutPlanId,
    required this.setInfo,
  });

  WorkoutRecord copyWith({
    String? exerciseName,
    List<String>? targetMuscles,
    int? trackingFieldId,
    int? workoutPlanId,
    List<SetInfo>? setInfo,
  }) =>
      WorkoutRecord(
        exerciseName: exerciseName ?? this.exerciseName,
        targetMuscles: targetMuscles ?? this.targetMuscles,
        trackingFieldId: trackingFieldId ?? this.trackingFieldId,
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        setInfo: setInfo ?? this.setInfo,
      );

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecordFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutRecordToJson(this);
}
