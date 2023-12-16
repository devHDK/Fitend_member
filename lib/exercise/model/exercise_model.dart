import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/exercise/model/target_muscle_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 5)
class Exercise {
  @HiveField(1)
  final int workoutPlanId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final int trackingFieldId;
  @HiveField(5)
  final String trainerNickname;
  @HiveField(6)
  final String trainerProfileImage;
  @HiveField(7)
  final List<TargetMuscle> targetMuscles;
  @HiveField(8)
  final List<ExerciseVideo> videos;
  @HiveField(9)
  final List<SetInfo> setInfo;
  @HiveField(10)
  final int? circuitGroupNum;
  @HiveField(11)
  final int? circuitSeq;
  @HiveField(12)
  final String? setType;
  @HiveField(13)
  final bool? isVideoRecord;

  Exercise({
    required this.workoutPlanId,
    required this.name,
    required this.description,
    required this.trackingFieldId,
    required this.trainerNickname,
    required this.trainerProfileImage,
    required this.targetMuscles,
    required this.videos,
    required this.setInfo,
    this.circuitGroupNum,
    this.circuitSeq,
    this.setType,
    this.isVideoRecord,
  });

  Exercise copyWith({
    int? workoutPlanId,
    String? name,
    String? description,
    int? trackingFieldId,
    String? trainerNickname,
    String? trainerProfileImage,
    List<TargetMuscle>? targetMuscles,
    List<ExerciseVideo>? videos,
    List<SetInfo>? setInfo,
    int? circuitGroupNum,
    int? circuitSeq,
    String? setType,
    bool? isVideoRecord,
  }) =>
      Exercise(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        name: name ?? this.name,
        description: description ?? this.description,
        trackingFieldId: trackingFieldId ?? this.trackingFieldId,
        trainerNickname: trainerNickname ?? this.trainerNickname,
        trainerProfileImage: trainerProfileImage ?? this.trainerProfileImage,
        targetMuscles: targetMuscles ?? this.targetMuscles,
        videos: videos ?? this.videos,
        setInfo: setInfo ?? this.setInfo,
        circuitGroupNum: circuitGroupNum ?? this.circuitGroupNum,
        circuitSeq: circuitSeq ?? this.circuitSeq,
        setType: setType ?? this.setType,
        isVideoRecord: isVideoRecord ?? this.isVideoRecord,
      );

  static Exercise clone({required Exercise exercise}) {
    return Exercise(
      workoutPlanId: exercise.workoutPlanId,
      name: exercise.name,
      description: exercise.description,
      trackingFieldId: exercise.trackingFieldId,
      trainerNickname: exercise.trainerNickname,
      trainerProfileImage: exercise.trainerProfileImage,
      targetMuscles: exercise.targetMuscles,
      videos: exercise.videos,
      setInfo: exercise.setInfo,
      circuitGroupNum: exercise.circuitGroupNum,
      circuitSeq: exercise.circuitSeq,
      setType: exercise.setType,
      isVideoRecord: exercise.isVideoRecord,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
