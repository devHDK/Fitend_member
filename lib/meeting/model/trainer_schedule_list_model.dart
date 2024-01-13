import 'package:json_annotation/json_annotation.dart';

part 'trainer_schedule_list_model.g.dart';

@JsonSerializable()
class TrainerScheduleList {
  @JsonKey(name: "data")
  final List<TrainerSchedule> data;

  TrainerScheduleList({
    required this.data,
  });

  TrainerScheduleList copyWith({
    List<TrainerSchedule>? data,
  }) =>
      TrainerScheduleList(
        data: data ?? this.data,
      );

  factory TrainerScheduleList.fromJson(Map<String, dynamic> json) =>
      _$TrainerScheduleListFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerScheduleListToJson(this);
}

@JsonSerializable()
class TrainerSchedule {
  @JsonKey(name: "startDate")
  final DateTime startDate;
  @JsonKey(name: "schedules")
  final List<TrainerScheduleDetail> schedules;

  TrainerSchedule({
    required this.startDate,
    required this.schedules,
  });

  TrainerSchedule copyWith({
    DateTime? startDate,
    List<TrainerScheduleDetail>? schedules,
  }) =>
      TrainerSchedule(
        startDate: startDate ?? this.startDate,
        schedules: schedules ?? this.schedules,
      );

  factory TrainerSchedule.fromJson(Map<String, dynamic> json) =>
      _$TrainerScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerScheduleToJson(this);
}

@JsonSerializable()
class TrainerScheduleDetail {
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "endTime")
  final DateTime endTime;
  @JsonKey(name: "startTime")
  final DateTime startTime;

  TrainerScheduleDetail({
    required this.type,
    required this.endTime,
    required this.startTime,
  });

  TrainerScheduleDetail copyWith({
    String? type,
    DateTime? endTime,
    DateTime? startTime,
  }) =>
      TrainerScheduleDetail(
        type: type ?? this.type,
        endTime: endTime ?? this.endTime,
        startTime: startTime ?? this.startTime,
      );

  factory TrainerScheduleDetail.fromJson(Map<String, dynamic> json) =>
      _$TrainerScheduleDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerScheduleDetailToJson(this);
}
