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

  WorkoutProcessModel({
    required this.exerciseIndex,
    required this.maxExerciseIndex,
    required this.setInfoCompleteList,
    required this.maxSetInfoList,
    required this.exercises,
    required this.modifiedExercises,
    required this.workoutFinished,
    required this.groupCounts,
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
      );

  factory WorkoutProcessModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProcessModelToJson(this);
}
