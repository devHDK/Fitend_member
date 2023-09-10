import 'package:json_annotation/json_annotation.dart';
part 'schedule_record_model.g.dart';

@JsonSerializable()
class ScheduleRecordsModel {
  @JsonKey(name: "workoutScheduleId")
  final int? workoutScheduleId;
  @JsonKey(name: "heartRates")
  final List<int>? heartRates;
  @JsonKey(name: "workoutDuration")
  final int? workoutDuration;

  ScheduleRecordsModel({
    this.workoutScheduleId,
    this.heartRates,
    this.workoutDuration,
  });

  ScheduleRecordsModel copyWith({
    int? workoutScheduleId,
    List<int>? heartRates,
    int? workoutDuration,
  }) =>
      ScheduleRecordsModel(
        workoutScheduleId: workoutScheduleId ?? this.workoutScheduleId,
        heartRates: heartRates ?? this.heartRates,
        workoutDuration: workoutDuration ?? this.workoutDuration,
      );

  factory ScheduleRecordsModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleRecordsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleRecordsModelToJson(this);
}
