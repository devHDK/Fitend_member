import 'package:json_annotation/json_annotation.dart';

part 'post_meeting_create_model.g.dart';

@JsonSerializable()
class PostMeetingCreateModel {
  @JsonKey(name: "trainerId")
  final int trainerId;
  @JsonKey(name: "startTime")
  final DateTime startTime;
  @JsonKey(name: "endTime")
  final DateTime endTime;

  PostMeetingCreateModel({
    required this.trainerId,
    required this.startTime,
    required this.endTime,
  });

  PostMeetingCreateModel copyWith({
    int? trainerId,
    DateTime? startTime,
    DateTime? endTime,
  }) =>
      PostMeetingCreateModel(
        trainerId: trainerId ?? this.trainerId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
      );

  factory PostMeetingCreateModel.fromJson(Map<String, dynamic> json) =>
      _$PostMeetingCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostMeetingCreateModelToJson(this);
}
