import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
part 'schedule_record_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 8)
class ScheduleRecordsModel {
  @JsonKey(name: "workoutScheduleId")
  @HiveField(1)
  final int? workoutScheduleId;
  @JsonKey(name: "heartRates")
  @HiveField(2)
  final List<int>? heartRates;
  @JsonKey(name: "workoutDuration")
  @HiveField(3)
  final int? workoutDuration;
  @HiveField(4)
  final int? calories;

  ScheduleRecordsModel({
    this.workoutScheduleId,
    this.heartRates,
    this.workoutDuration,
    this.calories,
  });

  ScheduleRecordsModel copyWith({
    int? workoutScheduleId,
    List<int>? heartRates,
    int? workoutDuration,
    int? calories,
  }) =>
      ScheduleRecordsModel(
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
        heartRates: heartRates ?? this.heartRates,
        workoutDuration: workoutDuration ?? this.workoutDuration,
        calories: calories ?? this.calories,
      );

  factory ScheduleRecordsModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleRecordsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleRecordsModelToJson(this);
}
