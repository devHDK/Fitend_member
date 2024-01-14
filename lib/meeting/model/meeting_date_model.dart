import 'package:fitend_member/common/utils/data_utils.dart';
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
  @JsonKey(
    name: "endTime",
    fromJson: DataUtils.dateTimeToLocal,
  )
  final DateTime endTime;
  @JsonKey(
    name: "startTime",
    fromJson: DataUtils.dateTimeToLocal,
  )
  final DateTime startTime;
  @JsonKey(name: "type")
  final String type;
  bool? isAvail;

  TrainerSchedule({
    required this.endTime,
    required this.startTime,
    required this.type,
    required this.isAvail,
  });

  TrainerSchedule copyWith({
    DateTime? endTime,
    DateTime? startTime,
    String? type,
    bool? isAvail,
  }) =>
      TrainerSchedule(
        endTime: endTime ?? this.endTime,
        startTime: startTime ?? this.startTime,
        type: type ?? this.type,
        isAvail: isAvail ?? this.isAvail,
      );

  factory TrainerSchedule.fromJson(Map<String, dynamic> json) =>
      _$TrainerScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerScheduleToJson(this);
}
