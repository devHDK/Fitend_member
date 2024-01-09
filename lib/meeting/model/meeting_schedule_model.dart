import 'package:fitend_member/schedule/model/reservation_schedule_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_schedule_model.g.dart';

@JsonSerializable()
class MeetingScheduleModel {
  @JsonKey(name: "data")
  final List<MeetingData> data;

  MeetingScheduleModel({
    required this.data,
  });

  MeetingScheduleModel copyWith({
    List<MeetingData>? data,
  }) =>
      MeetingScheduleModel(
        data: data ?? this.data,
      );

  factory MeetingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingScheduleModelToJson(this);
}

@JsonSerializable()
class MeetingData {
  @JsonKey(name: "startDate")
  final String startDate;
  @JsonKey(name: "meetings")
  final List<Meeting> meetings;

  MeetingData({
    required this.startDate,
    required this.meetings,
  });

  MeetingData copyWith({
    String? startDate,
    List<Meeting>? meetings,
  }) =>
      MeetingData(
        startDate: startDate ?? this.startDate,
        meetings: meetings ?? this.meetings,
      );

  factory MeetingData.fromJson(Map<String, dynamic> json) =>
      _$MeetingDataFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingDataToJson(this);
}

@JsonSerializable()
class Meeting {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "status")
  final String status;
  @JsonKey(name: "endTime")
  final String endTime;
  @JsonKey(name: "trainer")
  final Trainer trainer;
  @JsonKey(name: "startTime")
  final String startTime;
  @JsonKey(name: "userNickname")
  final String userNickname;

  Meeting({
    required this.id,
    required this.status,
    required this.endTime,
    required this.trainer,
    required this.startTime,
    required this.userNickname,
  });

  Meeting copyWith({
    int? id,
    String? status,
    String? endTime,
    Trainer? trainer,
    String? startTime,
    String? userNickname,
  }) =>
      Meeting(
        id: id ?? this.id,
        status: status ?? this.status,
        endTime: endTime ?? this.endTime,
        trainer: trainer ?? this.trainer,
        startTime: startTime ?? this.startTime,
        userNickname: userNickname ?? this.userNickname,
      );

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingToJson(this);
}
