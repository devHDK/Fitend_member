import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'workout_model.g.dart';

abstract class WorkoutModelBase {}

class WorkoutModelLoading extends WorkoutModelBase {}

class WorkoutModelError extends WorkoutModelBase {
  final String message;

  WorkoutModelError({required this.message});
}

@JsonSerializable()
class WorkoutModel extends WorkoutModelBase {
  final int workoutScheduleId;
  final String startDate;
  final String workoutTitle;
  final String workoutSubTitle;
  final List<String> targetMuscleTypes;
  final String workoutTotalTime;
  final bool isWorkoutComplete;
  final bool isRecord;
  final List<Exercise> exercises;

  WorkoutModel({
    required this.workoutScheduleId,
    required this.startDate,
    required this.workoutTitle,
    required this.workoutSubTitle,
    required this.targetMuscleTypes,
    required this.workoutTotalTime,
    required this.isWorkoutComplete,
    required this.exercises,
    required this.isRecord,
  });

  WorkoutModel copyWith({
    int? workoutScheduleId,
    String? startDate,
    String? workoutTitle,
    String? workoutSubTitle,
    List<String>? targetMuscleTypes,
    String? workoutTotalTime,
    bool? isWorkoutComplete,
    bool? isRecord,
    List<Exercise>? exercises,
  }) =>
      WorkoutModel(
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
        startDate: startDate ?? this.startDate,
        workoutTitle: workoutTitle ?? this.workoutTitle,
        workoutSubTitle: workoutSubTitle ?? this.workoutSubTitle,
        targetMuscleTypes: targetMuscleTypes ?? this.targetMuscleTypes,
        workoutTotalTime: workoutTotalTime ?? this.workoutTotalTime,
        isWorkoutComplete: isWorkoutComplete ?? this.isWorkoutComplete,
        isRecord: isRecord ?? this.isRecord,
        exercises: exercises ?? this.exercises,
      );

  static WorkoutModel clone({required WorkoutModel model}) {
    return WorkoutModel(
      workoutScheduleId: model.workoutScheduleId,
      startDate: model.startDate,
      workoutTitle: model.workoutTitle,
      workoutSubTitle: model.workoutSubTitle,
      targetMuscleTypes: model.targetMuscleTypes,
      workoutTotalTime: model.workoutTotalTime,
      isWorkoutComplete: model.isWorkoutComplete,
      exercises: model.exercises,
      isRecord: model.isRecord,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);
}
