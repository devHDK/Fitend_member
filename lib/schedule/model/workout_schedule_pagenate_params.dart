import 'package:json_annotation/json_annotation.dart';
part 'workout_schedule_pagenate_params.g.dart';

@JsonSerializable()
class SchedulePagenateParams {
  final DateTime startDate;
  final int interval;

  SchedulePagenateParams({
    required this.startDate,
    required this.interval,
  });

  SchedulePagenateParams copyWith({
    DateTime? startDate,
    int? interval,
  }) =>
      SchedulePagenateParams(
        startDate: startDate ?? this.startDate,
        interval: interval ?? this.interval,
      );

  factory SchedulePagenateParams.fromJson(Map<String, dynamic> json) =>
      _$SchedulePagenateParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SchedulePagenateParamsToJson(this);
}
