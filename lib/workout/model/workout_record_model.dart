import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_record_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class WorkoutRecordModel {
  @HiveField(1)
  final int workoutPlanId;
  @HiveField(2)
  final List<SetInfo> setInfo;

  WorkoutRecordModel({
    required this.workoutPlanId,
    required this.setInfo,
  });

  WorkoutRecordModel copyWith({
    int? workoutPlanId,
    List<SetInfo>? setInfo,
  }) =>
      WorkoutRecordModel(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        setInfo: setInfo ?? this.setInfo,
      );

  factory WorkoutRecordModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutRecordModelToJson(this);
}
