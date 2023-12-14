import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_process_model.g.dart';

abstract class WorkoutProcessModelBase {}

class WorkoutProcessModelLoading extends WorkoutProcessModelBase {}

@JsonSerializable()
class WorkoutProcessModel extends WorkoutProcessModelBase {
  int exerciseIndex;
  int maxExerciseIndex;
  List<int> setInfoCompleteList;
  List<int> maxSetInfoList;
  List<Exercise> exercises;
  List<Exercise> modifiedExercises;
  bool workoutFinished;
  Map<int, int> groupCounts;
  int totalTime;
  bool isQuitting;
  bool isSwipeGuide;
  bool isWorkoutChangeGuide;
  bool isThreadGuide;

  WorkoutProcessModel({
    required this.exerciseIndex,
    required this.maxExerciseIndex,
    required this.setInfoCompleteList,
    required this.maxSetInfoList,
    required this.exercises,
    required this.modifiedExercises,
    required this.workoutFinished,
    required this.groupCounts,
    required this.totalTime,
    required this.isQuitting,
    required this.isSwipeGuide,
    required this.isWorkoutChangeGuide,
    required this.isThreadGuide,
  });

  WorkoutProcessModel copyWith({
    int? exerciseIndex,
    int? recentSetIndex,
    int? maxExerciseIndex,
    List<int>? setInfoCompleteList,
    List<int>? maxSetInfoList,
    List<Exercise>? exercises,
    List<Exercise>? modifiedExercises,
    bool? workoutFinished,
    Map<int, int>? groupCounts,
    int? totalTime,
    bool? isQuitting,
    bool? isSwipeGuide,
    bool? isWorkoutChangeGuide,
    bool? isThreadGuide,
  }) =>
      WorkoutProcessModel(
        exerciseIndex: exerciseIndex ?? this.exerciseIndex,
        maxExerciseIndex: maxExerciseIndex ?? this.maxExerciseIndex,
        setInfoCompleteList: setInfoCompleteList ?? this.setInfoCompleteList,
        maxSetInfoList: maxSetInfoList ?? this.maxSetInfoList,
        exercises: exercises ?? this.exercises,
        modifiedExercises: modifiedExercises ?? this.modifiedExercises,
        workoutFinished: workoutFinished ?? this.workoutFinished,
        groupCounts: groupCounts ?? this.groupCounts,
        totalTime: totalTime ?? this.totalTime,
        isQuitting: isQuitting ?? this.isQuitting,
        isSwipeGuide: isSwipeGuide ?? this.isSwipeGuide,
        isWorkoutChangeGuide: isWorkoutChangeGuide ?? this.isWorkoutChangeGuide,
        isThreadGuide: isThreadGuide ?? this.isThreadGuide,
      );

  factory WorkoutProcessModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProcessModelToJson(this);
}
