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
