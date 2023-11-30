import 'package:json_annotation/json_annotation.dart';

part 'workout_history_model.g.dart';

abstract class WorkoutHistoryModelBase {}

class WorkoutHistoryModelError extends WorkoutHistoryModelBase {
  final String message;

  WorkoutHistoryModelError({
    required this.message,
  });
}

class WorkoutHistoryModelLoading extends WorkoutHistoryModelBase {}

@JsonSerializable()
class WorkoutHistoryModel extends WorkoutHistoryModelBase {
  @JsonKey(name: "data")
  final List<HistoryData> data;
  @JsonKey(name: "total")
  final int total;

  WorkoutHistoryModel({
    required this.data,
    required this.total,
  });

  WorkoutHistoryModel copyWith({
    List<HistoryData>? data,
    int? total,
  }) =>
      WorkoutHistoryModel(
        data: data ?? this.data,
        total: total ?? this.total,
      );

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutHistoryModelToJson(this);
}

class WorkoutHistoryModelFetchingMore extends WorkoutHistoryModel {
  WorkoutHistoryModelFetchingMore({
    required super.data,
    required super.total,
  });
}

@JsonSerializable()
class HistoryData {
  @JsonKey(name: "startDate")
  final String startDate;
  @JsonKey(name: "workoutRecordId")
  final int workoutRecordId;
  @JsonKey(name: "workoutPlanId")
  final int workoutPlanId;
  @JsonKey(name: "exerciseName")
  final String exerciseName;
  @JsonKey(name: "setInfo")
  final List<SetInfo> setInfo;

  HistoryData({
    required this.startDate,
    required this.workoutRecordId,
    required this.workoutPlanId,
    required this.exerciseName,
    required this.setInfo,
  });

  HistoryData copyWith({
    String? startDate,
    int? workoutRecordId,
    int? workoutPlanId,
    String? exerciseName,
    List<SetInfo>? setInfo,
  }) =>
      HistoryData(
        startDate: startDate ?? this.startDate,
        workoutRecordId: workoutRecordId ?? this.workoutRecordId,
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        exerciseName: exerciseName ?? this.exerciseName,
        setInfo: setInfo ?? this.setInfo,
      );

  factory HistoryData.fromJson(Map<String, dynamic> json) =>
      _$HistoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryDataToJson(this);
}

@JsonSerializable()
class SetInfo {
  @JsonKey(name: "reps")
  final int reps;
  @JsonKey(name: "index")
  final int index;
  @JsonKey(name: "weight")
  final int weight;
  @JsonKey(name: "seconds")
  final int seconds;

  SetInfo({
    required this.reps,
    required this.index,
    required this.weight,
    required this.seconds,
  });

  SetInfo copyWith({
    int? reps,
    int? index,
    int? weight,
    int? seconds,
  }) =>
      SetInfo(
        reps: reps ?? this.reps,
        index: index ?? this.index,
        weight: weight ?? this.weight,
        seconds: seconds ?? this.seconds,
      );

  factory SetInfo.fromJson(Map<String, dynamic> json) =>
      _$SetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SetInfoToJson(this);
}
