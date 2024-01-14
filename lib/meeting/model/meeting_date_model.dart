import 'package:json_annotation/json_annotation.dart';

part 'meeting_date_model.g.dart';

abstract class MeetingDateModelBase {}

class MeetingDateModelError extends MeetingDateModelBase {
  final String message;

  MeetingDateModelError({
    required this.message,
  });
}

class MeetingDateModelLoading extends MeetingDateModelBase {}

@JsonSerializable()
class MeetingDateModel extends MeetingDateModelBase {
  @JsonKey(name: "data")
  final List<ScheduleData> data;

  MeetingDateModel({
    required this.data,
  });

  MeetingDateModel copyWith({
    List<ScheduleData>? data,
  }) =>
      MeetingDateModel(
        data: data ?? this.data,
      );

  factory MeetingDateModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingDateModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingDateModelToJson(this);
}

@JsonSerializable()
class ScheduleData {
  @JsonKey(name: "startDate")
  final DateTime startDate;
  @JsonKey(name: "schedules")
  final List<TrainerSchedule> schedules;

  ScheduleData({
    required this.startDate,
    required this.schedules,
  });

  ScheduleData copyWith({
    DateTime? startDate,
    List<TrainerSchedule>? schedules,
  }) =>
      ScheduleData(
        startDate: startDate ?? this.startDate,
        schedules: schedules ?? this.schedules,
      );

  factory ScheduleData.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDataFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleDataToJson(this);
}

@JsonSerializable()
class TrainerSchedule {
  @JsonKey(name: "endTime")
  final DateTime endTime;
  @JsonKey(name: "startTime")
  final DateTime startTime;
  @JsonKey(name: "type")
  final String type;

  TrainerSchedule({
    required this.endTime,
    required this.startTime,
    required this.type,
  });

  TrainerSchedule copyWith({
    DateTime? endTime,
    DateTime? startTime,
    String? type,
  }) =>
      TrainerSchedule(
        endTime: endTime ?? this.endTime,
        startTime: startTime ?? this.startTime,
        type: type ?? this.type,
      );

  factory TrainerSchedule.fromJson(Map<String, dynamic> json) =>
      _$TrainerScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerScheduleToJson(this);
}
