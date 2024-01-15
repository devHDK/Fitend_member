import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_schedule_model.g.dart';

@JsonSerializable()
class MeetingScheduleModel {
  @JsonKey(name: "data")
  final List<MeetingScheduleData> data;

  MeetingScheduleModel({
    required this.data,
  });

  MeetingScheduleModel copyWith({
    List<MeetingScheduleData>? data,
  }) =>
      MeetingScheduleModel(
        data: data ?? this.data,
      );

  factory MeetingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingScheduleModelToJson(this);
}

@JsonSerializable()
class MeetingScheduleData {
  @JsonKey(name: "startDate")
  final DateTime startDate;
  @JsonKey(name: "meetings")
  final List<MeetingSchedule> meetings;

  MeetingScheduleData({
    required this.startDate,
    required this.meetings,
  });

  MeetingScheduleData copyWith({
    DateTime? startDate,
    List<MeetingSchedule>? meetings,
  }) =>
      MeetingScheduleData(
        startDate: startDate ?? this.startDate,
        meetings: meetings ?? this.meetings,
      );

  factory MeetingScheduleData.fromJson(Map<String, dynamic> json) =>
      _$MeetingScheduleDataFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingScheduleDataToJson(this);
}

@JsonSerializable()
class MeetingSchedule {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "status")
  final String status;
  @JsonKey(name: "endTime")
  final DateTime endTime;
  @JsonKey(name: "trainer")
  final ThreadTrainer trainer;
  @JsonKey(name: "startTime")
  final DateTime startTime;
  @JsonKey(name: "userNickname")
  final String userNickname;
  bool? selected;

  MeetingSchedule({
    required this.id,
    required this.status,
    required this.endTime,
    required this.trainer,
    required this.startTime,
    required this.userNickname,
    this.selected,
  });

  MeetingSchedule copyWith({
    int? id,
    String? status,
    DateTime? endTime,
    ThreadTrainer? trainer,
    DateTime? startTime,
    String? userNickname,
    bool? selected,
  }) =>
      MeetingSchedule(
        id: id ?? this.id,
        status: status ?? this.status,
        endTime: endTime ?? this.endTime,
        trainer: trainer ?? this.trainer,
        startTime: startTime ?? this.startTime,
        userNickname: userNickname ?? this.userNickname,
        selected: selected ?? this.selected,
      );

  factory MeetingSchedule.fromJson(Map<String, dynamic> json) =>
      _$MeetingScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingScheduleToJson(this);
}
