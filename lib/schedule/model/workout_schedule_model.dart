import 'package:json_annotation/json_annotation.dart';
part 'workout_schedule_model.g.dart';

@JsonSerializable()
class WorkoutScheduleModel {
  final List<Datum> data;

  WorkoutScheduleModel({
    required this.data,
  });

  WorkoutScheduleModel copyWith({
    List<Datum>? data,
  }) =>
      WorkoutScheduleModel(
        data: data ?? this.data,
      );

  factory WorkoutScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutScheduleModelFromJson(json);
}

@JsonSerializable()
class Datum {
  final DateTime startDate;
  final List<Workout> workouts;

  Datum({
    required this.startDate,
    required this.workouts,
  });

  Datum copyWith({
    DateTime? startDate,
    List<Workout>? workouts,
  }) =>
      Datum(
        startDate: startDate ?? this.startDate,
        workouts: workouts ?? this.workouts,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);
}

@JsonSerializable()
class Workout {
  final int seq;
  final String title;
  final String subTitle;
  final bool isComplete;
  final int workoutScheduleId;

  Workout({
    required this.seq,
    required this.title,
    required this.subTitle,
    required this.isComplete,
    required this.workoutScheduleId,
  });

  Workout copyWith({
    int? seq,
    String? title,
    String? subTitle,
    bool? isComplete,
    int? workoutScheduleId,
  }) =>
      Workout(
        seq: seq ?? this.seq,
        title: title ?? this.title,
        subTitle: subTitle ?? this.subTitle,
        isComplete: isComplete ?? this.isComplete,
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
      );

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);
}
