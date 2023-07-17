import 'package:json_annotation/json_annotation.dart';
part 'workout_schedule_pagenate_params.g.dart';

@JsonSerializable()
class WorkoutSchedulePagenateParams {
  final DateTime startDate;
  final int interval;

  WorkoutSchedulePagenateParams({
    required this.startDate,
    required this.interval,
  });

  WorkoutSchedulePagenateParams copyWith({
    DateTime? startDate,
    int? interval,
  }) =>
      WorkoutSchedulePagenateParams(
        startDate: startDate ?? this.startDate,
        interval: interval ?? this.interval,
      );

  factory WorkoutSchedulePagenateParams.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSchedulePagenateParamsFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSchedulePagenateParamsToJson(this);
}
