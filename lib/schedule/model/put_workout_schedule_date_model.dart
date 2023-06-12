import 'package:json_annotation/json_annotation.dart';

part 'put_workout_schedule_date_model.g.dart';

@JsonSerializable()
class PutWorkoutScheduleModel {
  final String startDate;
  final int seq;

  PutWorkoutScheduleModel({
    required this.startDate,
    required this.seq,
  });

  PutWorkoutScheduleModel copyWith({
    String? startDate,
    int? seq,
  }) =>
      PutWorkoutScheduleModel(
        startDate: startDate ?? this.startDate,
        seq: seq ?? this.seq,
      );

  factory PutWorkoutScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$PutWorkoutScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$PutWorkoutScheduleModelToJson(this);
}
