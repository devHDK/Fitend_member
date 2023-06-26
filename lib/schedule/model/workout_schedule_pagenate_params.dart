import 'package:json_annotation/json_annotation.dart';
part 'workout_schedule_pagenate_params.g.dart';

@JsonSerializable()
class WorkoutSchedulePagenateParams {
  final DateTime startDate;

  WorkoutSchedulePagenateParams({
    required this.startDate,
  });

  WorkoutSchedulePagenateParams copyWith({
    DateTime? startDate,
  }) =>
      WorkoutSchedulePagenateParams(
        startDate: startDate ?? this.startDate,
      );

  factory WorkoutSchedulePagenateParams.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSchedulePagenateParamsFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSchedulePagenateParamsToJson(this);
}
