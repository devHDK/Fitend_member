import 'package:json_annotation/json_annotation.dart';

part 'get_workout_history_params.g.dart';

@JsonSerializable()
class GetWorkoutHistoryParams {
  @JsonKey(name: "workoutPlanId")
  final int workoutPlanId;
  @JsonKey(name: "start")
  final int start;
  @JsonKey(name: "perPage")
  final int perPage;

  GetWorkoutHistoryParams({
    required this.workoutPlanId,
    required this.start,
    required this.perPage,
  });

  GetWorkoutHistoryParams copyWith({
    int? workoutPlanId,
    int? start,
    int? perPage,
  }) =>
      GetWorkoutHistoryParams(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        start: start ?? this.start,
        perPage: perPage ?? this.perPage,
      );

  factory GetWorkoutHistoryParams.fromJson(Map<String, dynamic> json) =>
      _$GetWorkoutHistoryParamsFromJson(json);

  Map<String, dynamic> toJson() => _$GetWorkoutHistoryParamsToJson(this);
}
