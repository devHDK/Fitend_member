import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_process_model.g.dart';

@JsonSerializable()
class WorkoutProcessModel {
  final int recentWorkoutIndex;
  final int recentSetIndex;
  final int maxExerciseIndex;
  final List<int> setInfoCompleteList;
  final List<int> maxSetInfoList;
  final Workout workout;

  WorkoutProcessModel({
    required this.recentWorkoutIndex,
    required this.recentSetIndex,
    required this.maxExerciseIndex,
    required this.setInfoCompleteList,
    required this.maxSetInfoList,
    required this.workout,
  });

  WorkoutProcessModel copyWith({
    int? recentWorkoutIndex,
    int? recentSetIndex,
    int? maxExerciseIndex,
    List<int>? setInfoCompleteList,
    List<int>? maxSetInfoList,
    Workout? workout,
  }) =>
      WorkoutProcessModel(
        recentWorkoutIndex: recentWorkoutIndex ?? this.recentWorkoutIndex,
        recentSetIndex: recentSetIndex ?? this.recentSetIndex,
        maxExerciseIndex: maxExerciseIndex ?? this.maxExerciseIndex,
        setInfoCompleteList: setInfoCompleteList ?? this.setInfoCompleteList,
        maxSetInfoList: maxSetInfoList ?? this.maxSetInfoList,
        workout: workout ?? this.workout,
      );

  factory WorkoutProcessModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProcessModelToJson(this);
}
