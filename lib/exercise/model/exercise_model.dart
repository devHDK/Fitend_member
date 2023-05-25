import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/exercise/model/target_muscle_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class Exercise {
  final int workoutPlanId;
  final String name;
  final String description;
  final int trackingFieldId;
  final List<TargetMuscle> targetMuscles;
  final List<ExerciseVideo> videos;
  final List<SetInfo> setInfo;

  Exercise({
    required this.workoutPlanId,
    required this.name,
    required this.description,
    required this.trackingFieldId,
    required this.targetMuscles,
    required this.videos,
    required this.setInfo,
  });

  Exercise copyWith({
    int? workoutPlanId,
    String? name,
    String? description,
    int? trackingFieldId,
    List<TargetMuscle>? targetMuscles,
    List<ExerciseVideo>? videos,
    List<SetInfo>? setInfo,
  }) =>
      Exercise(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        name: name ?? this.name,
        description: description ?? this.description,
        trackingFieldId: trackingFieldId ?? this.trackingFieldId,
        targetMuscles: targetMuscles ?? this.targetMuscles,
        videos: videos ?? this.videos,
        setInfo: setInfo ?? this.setInfo,
      );

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}
