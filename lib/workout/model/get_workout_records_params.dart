import 'package:json_annotation/json_annotation.dart';

part 'get_workout_records_params.g.dart';

@JsonSerializable()
class GetWorkoutRecordsParams {
  final int workoutScheduleId;

  GetWorkoutRecordsParams({
    required this.workoutScheduleId,
  });

  factory GetWorkoutRecordsParams.fromJson(Map<String, dynamic> json) =>
      _$GetWorkoutRecordsParamsFromJson(json);

  Map<String, dynamic> toJson() => _$GetWorkoutRecordsParamsToJson(this);
}
