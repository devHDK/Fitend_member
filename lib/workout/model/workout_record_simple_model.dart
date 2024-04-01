import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_record_simple_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class WorkoutRecordSimple {
  @HiveField(1)
  final int workoutPlanId;
  @HiveField(2)
  final List<SetInfo> setInfo;

  WorkoutRecordSimple({
    required this.workoutPlanId,
    required this.setInfo,
  });

  WorkoutRecordSimple copyWith({
    int? workoutPlanId,
    List<SetInfo>? setInfo,
  }) =>
      WorkoutRecordSimple(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        setInfo: setInfo ?? this.setInfo,
      );

  factory WorkoutRecordSimple.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecordSimpleFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutRecordSimpleToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class ExerciseSimple {
  final int workoutPlanId;
  final List<SetInfo> setInfo;
  final String name;
  final int trackingFieldId;
  final int? circuitGroupNum;
  final int? circuitSeq;
  final String? setType;
  bool? isVideoRecord;

  ExerciseSimple({
    required this.workoutPlanId,
    required this.setInfo,
    required this.name,
    required this.trackingFieldId,
    this.circuitGroupNum,
    this.circuitSeq,
    this.setType,
    this.isVideoRecord,
  });

  ExerciseSimple copyWith({
    int? workoutPlanId,
    List<SetInfo>? setInfo,
    String? name,
    int? trackingFieldId,
    int? circuitGroupNum,
    int? circuitSeq,
    String? setType,
    bool? isVideoRecord,
  }) =>
      ExerciseSimple(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        setInfo: setInfo ?? this.setInfo,
        name: name ?? this.name,
        trackingFieldId: trackingFieldId ?? this.trackingFieldId,
        circuitGroupNum: circuitGroupNum ?? this.circuitGroupNum,
        circuitSeq: circuitSeq ?? this.circuitSeq,
        setType: setType ?? this.setType,
        isVideoRecord: isVideoRecord ?? this.isVideoRecord,
      );

  factory ExerciseSimple.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSimpleFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSimpleToJson(this);
}
