import 'package:json_annotation/json_annotation.dart';
part 'workout_schedule_model.g.dart';

abstract class WorkoutScheduleModelBase {}

class WorkoutScheduleModelError extends WorkoutScheduleModelBase {
  final String message;

  WorkoutScheduleModelError({
    required this.message,
  });
}

class WorkoutScheduleModelLoading extends WorkoutScheduleModelBase {}

@JsonSerializable()
class WorkoutScheduleModel extends WorkoutScheduleModelBase {
  final List<WorkoutData>? data;

  WorkoutScheduleModel({
    this.data,
  });

  WorkoutScheduleModel copyWith({
    List<WorkoutData>? data,
  }) =>
      WorkoutScheduleModel(
        data: data ?? this.data,
      );

  factory WorkoutScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutScheduleModelToJson(this);
}

class WorkoutScheduleFetchingMore extends WorkoutScheduleModel {
  WorkoutScheduleFetchingMore({
    required super.data,
  });
}

class WorkoutScheduleRefetching extends WorkoutScheduleModel {
  WorkoutScheduleRefetching({
    required super.data,
  });
}

@JsonSerializable()
class WorkoutData {
  final DateTime startDate;
  List<Workout>? workouts;

  WorkoutData({
    required this.startDate,
    this.workouts,
  });

  WorkoutData copyWith({
    DateTime? startDate,
    List<Workout>? workouts,
    bool? selected,
  }) =>
      WorkoutData(
        startDate: startDate ?? this.startDate,
        workouts: workouts ?? this.workouts,
      );

  factory WorkoutData.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDataFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutDataToJson(this);
}

@JsonSerializable()
class Workout {
  final int seq;
  final String title;
  final String subTitle;
  final bool isComplete;
  final bool isRecord;
  final int workoutScheduleId;
  bool? selected;

  Workout({
    required this.seq,
    required this.title,
    required this.subTitle,
    required this.isComplete,
    required this.isRecord,
    required this.workoutScheduleId,
    this.selected = false,
  });

  Workout copyWith({
    int? seq,
    String? title,
    String? subTitle,
    bool? isComplete,
    bool? isRecord,
    int? workoutScheduleId,
    bool? selected,
  }) =>
      Workout(
        seq: seq ?? this.seq,
        title: title ?? this.title,
        subTitle: subTitle ?? this.subTitle,
        isComplete: isComplete ?? this.isComplete,
        isRecord: isRecord ?? this.isRecord,
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
        selected: selected ?? this.selected,
      );

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
