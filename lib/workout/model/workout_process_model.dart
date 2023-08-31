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

  WorkoutProcessModel({
    required this.exerciseIndex,
    required this.maxExerciseIndex,
    required this.setInfoCompleteList,
    required this.maxSetInfoList,
    required this.exercises,
  });

  WorkoutProcessModel copyWith({
    int? exerciseIndex,
    int? recentSetIndex,
    int? maxExerciseIndex,
    List<int>? setInfoCompleteList,
    List<int>? maxSetInfoList,
    List<Exercise>? exercises,
  }) =>
      WorkoutProcessModel(
        exerciseIndex: exerciseIndex ?? this.exerciseIndex,
        maxExerciseIndex: maxExerciseIndex ?? this.maxExerciseIndex,
        setInfoCompleteList: setInfoCompleteList ?? this.setInfoCompleteList,
        maxSetInfoList: maxSetInfoList ?? this.maxSetInfoList,
        exercises: exercises ?? this.exercises,
      );

  factory WorkoutProcessModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProcessModelToJson(this);
}
