import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_watch_process_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutWatchProcessModel {
  @JsonKey(name: 'command')
  String command;
  @JsonKey(name: 'watchModel')
  WorkoutWatchModel? watchModel;

  WorkoutWatchProcessModel({
    required this.command,
    this.watchModel,
  });

  static WorkoutWatchProcessModel fromWorkoutProcessModel({
    required String command,
    required WorkoutProcessModel model,
  }) =>
      WorkoutWatchProcessModel(
        command: command,
        watchModel: WorkoutWatchModel(
          exerciseIndex: model.exerciseIndex,
          maxExerciseIndex: model.maxExerciseIndex,
          setInfoCompleteList: model.setInfoCompleteList,
          maxSetInfoList: model.maxSetInfoList,
          totalTime: model.totalTime,
          exercises: model.modifiedExercises
              .map(
                (e) => ExerciseSimple(
                  workoutPlanId: e.workoutPlanId,
                  setInfo: e.setInfo,
                  name: e.name,
                  trackingFieldId: e.trackingFieldId,
                  circuitGroupNum: e.circuitGroupNum,
                  circuitSeq: e.circuitSeq,
                  isVideoRecord: e.isVideoRecord,
                  setType: e.setType,
                ),
              )
              .toList(),
          workoutFinished: model.workoutFinished,
          groupCounts: model.groupCounts,
          isQuitting: model.isQuitting,
        ),
      );

  factory WorkoutWatchProcessModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutWatchProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutWatchProcessModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WorkoutWatchModel {
  @JsonKey(name: 'exerciseIndex')
  int exerciseIndex;
  @JsonKey(name: 'maxExerciseIndex')
  int maxExerciseIndex;
  @JsonKey(name: 'setInfoCompleteList')
  List<int> setInfoCompleteList;
  @JsonKey(name: 'maxSetInfoList')
  List<int> maxSetInfoList;
  @JsonKey(name: 'exercises')
  List<ExerciseSimple> exercises;
  @JsonKey(name: 'workoutFinished')
  bool? workoutFinished;
  @JsonKey(name: 'groupCounts')
  Map<int, int>? groupCounts;
  @JsonKey(name: 'totalTime')
  int totalTime;
  @JsonKey(name: 'isQuitting')
  bool? isQuitting;

  WorkoutWatchModel({
    required this.exerciseIndex,
    required this.maxExerciseIndex,
    required this.setInfoCompleteList,
    required this.maxSetInfoList,
    required this.exercises,
    required this.workoutFinished,
    required this.groupCounts,
    required this.totalTime,
    required this.isQuitting,
  });

  WorkoutWatchModel copyWith({
    int? exerciseIndex,
    int? recentSetIndex,
    int? maxExerciseIndex,
    List<int>? setInfoCompleteList,
    List<int>? maxSetInfoList,
    List<ExerciseSimple>? exercises,
    bool? workoutFinished,
    Map<int, int>? groupCounts,
    int? totalTime,
    bool? isQuitting,
  }) =>
      WorkoutWatchModel(
        exerciseIndex: exerciseIndex ?? this.exerciseIndex,
        maxExerciseIndex: maxExerciseIndex ?? this.maxExerciseIndex,
        setInfoCompleteList: setInfoCompleteList ?? this.setInfoCompleteList,
        maxSetInfoList: maxSetInfoList ?? this.maxSetInfoList,
        exercises: exercises ?? this.exercises,
        workoutFinished: workoutFinished ?? this.workoutFinished,
        groupCounts: groupCounts ?? this.groupCounts,
        totalTime: totalTime ?? this.totalTime,
        isQuitting: isQuitting ?? this.isQuitting,
      );

  factory WorkoutWatchModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutWatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutWatchModelToJson(this);
}
