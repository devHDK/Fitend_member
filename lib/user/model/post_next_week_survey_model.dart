import 'package:json_annotation/json_annotation.dart';

part 'post_next_week_survey_model.g.dart';

@JsonSerializable()
class PostNextWeekSurveyModel {
  @JsonKey(name: "mondayDate")
  final DateTime mondayDate;
  @JsonKey(name: "selectedDates")
  List<DateTime>? selectedDates;
  @JsonKey(name: "noSchedule")
  final bool noSchedule;

  PostNextWeekSurveyModel({
    required this.mondayDate,
    this.selectedDates,
    required this.noSchedule,
  });

  PostNextWeekSurveyModel copyWith({
    DateTime? mondayDate,
    List<DateTime>? selectedDates,
    bool? noSchedule,
  }) =>
      PostNextWeekSurveyModel(
        mondayDate: mondayDate ?? this.mondayDate,
        selectedDates: selectedDates ?? this.selectedDates,
        noSchedule: noSchedule ?? this.noSchedule,
      );

  factory PostNextWeekSurveyModel.fromJson(Map<String, dynamic> json) =>
      _$PostNextWeekSurveyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostNextWeekSurveyModelToJson(this);
}
