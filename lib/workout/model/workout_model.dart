import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
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
  final int trainerId;
  final String startDate;
  final String workoutTitle;
  final String workoutSubTitle;
  final List<String> targetMuscleTypes;
  final String workoutTotalTime;
  final bool isWorkoutComplete;
  final bool isRecord;
  final List<Exercise> exercises;
  List<Exercise>? modifiedExercises;
  List<WorkoutRecordSimple>? recordedExercises;
  bool? isProcessing;

  WorkoutModel({
    required this.workoutScheduleId,
    required this.trainerId,
    required this.startDate,
    required this.workoutTitle,
    required this.workoutSubTitle,
    required this.targetMuscleTypes,
    required this.workoutTotalTime,
    required this.isWorkoutComplete,
    required this.exercises,
    this.modifiedExercises,
    this.recordedExercises,
    required this.isRecord,
    this.isProcessing,
  });

  WorkoutModel copyWith({
    int? workoutScheduleId,
    int? trainerId,
    String? startDate,
    String? workoutTitle,
    String? workoutSubTitle,
    List<String>? targetMuscleTypes,
    String? workoutTotalTime,
    bool? isWorkoutComplete,
    bool? isRecord,
    List<Exercise>? exercises,
    List<Exercise>? modifiedExercises,
    List<WorkoutRecordSimple>? recordedExercises,
    bool? isProcessing,
  }) =>
      WorkoutModel(
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
        trainerId: trainerId ?? this.trainerId,
        startDate: startDate ?? this.startDate,
        workoutTitle: workoutTitle ?? this.workoutTitle,
        workoutSubTitle: workoutSubTitle ?? this.workoutSubTitle,
        targetMuscleTypes: targetMuscleTypes ?? this.targetMuscleTypes,
        workoutTotalTime: workoutTotalTime ?? this.workoutTotalTime,
        isWorkoutComplete: isWorkoutComplete ?? this.isWorkoutComplete,
        isRecord: isRecord ?? this.isRecord,
        exercises: exercises ?? this.exercises,
        modifiedExercises: modifiedExercises ?? this.modifiedExercises,
        recordedExercises: recordedExercises ?? this.recordedExercises,
        isProcessing: isProcessing ?? this.isProcessing,
      );

  static WorkoutModel clone({required WorkoutModel model}) {
    return WorkoutModel(
      workoutScheduleId: model.workoutScheduleId,
      trainerId: model.trainerId,
      startDate: model.startDate,
      workoutTitle: model.workoutTitle,
      workoutSubTitle: model.workoutSubTitle,
      targetMuscleTypes: model.targetMuscleTypes,
      workoutTotalTime: model.workoutTotalTime,
      isWorkoutComplete: model.isWorkoutComplete,
      exercises: model.exercises.map((exercise) {
        return Exercise(
          workoutPlanId: exercise.workoutPlanId,
          name: exercise.name,
          description: exercise.description,
          trackingFieldId: exercise.trackingFieldId,
          trainerNickname: exercise.trainerNickname,
          trainerProfileImage: exercise.trainerProfileImage,
          targetMuscles: exercise.targetMuscles,
          videos: exercise.videos,
          circuitGroupNum: exercise.circuitGroupNum,
          circuitSeq: exercise.circuitSeq,
          setType: exercise.setType,
          setInfo: exercise.setInfo.map((e) {
            return SetInfo(
              index: e.index,
              reps: e.reps,
              seconds: e.seconds,
              weight: e.weight,
            );
          }).toList(),
          isVideoRecord: exercise.isVideoRecord,
          devisionId: exercise.devisionId,
        );
      }).toList(),
      modifiedExercises: model.modifiedExercises,
      recordedExercises: model.recordedExercises,
      isRecord: model.isRecord,
      isProcessing: model.isProcessing,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutModelToJson(this);
}
