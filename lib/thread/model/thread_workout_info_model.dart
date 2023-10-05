import 'package:json_annotation/json_annotation.dart';

part 'thread_workout_info_model.g.dart';

@JsonSerializable()
class ThreadWorkoutInfo {
  @JsonKey(name: "workoutScheduleId")
  final int workoutScheduleId;
  @JsonKey(name: "targetMuscleIds")
  final List<int> targetMuscleIds;
  @JsonKey(name: "title")
  final String title;
  @JsonKey(name: "subTitle")
  final String subTitle;
  @JsonKey(name: "workoutDuration")
  int? workoutDuration;
  @JsonKey(name: "totalSet")
  final int totalSet;
  @JsonKey(name: "heartRate")
  int? heartRate;
  @JsonKey(name: "calories")
  int? calories;

  ThreadWorkoutInfo({
    required this.workoutScheduleId,
    required this.targetMuscleIds,
    required this.title,
    required this.subTitle,
    required this.workoutDuration,
    required this.totalSet,
    required this.heartRate,
    required this.calories,
  });

  ThreadWorkoutInfo copyWith({
    int? workoutScheduleId,
    List<int>? targetMuscleIds,
    String? title,
    String? subTitle,
    int? workoutDuration,
    int? totalSet,
    int? heartRate,
    int? calories,
  }) =>
      ThreadWorkoutInfo(
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
        targetMuscleIds: targetMuscleIds ?? this.targetMuscleIds,
        title: title ?? this.title,
        subTitle: subTitle ?? this.subTitle,
        workoutDuration: workoutDuration ?? this.workoutDuration,
        totalSet: totalSet ?? this.totalSet,
        heartRate: heartRate ?? this.heartRate,
        calories: calories ?? this.calories,
      );

  factory ThreadWorkoutInfo.fromJson(Map<String, dynamic> json) =>
      _$ThreadWorkoutInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadWorkoutInfoToJson(this);
}
