import 'package:json_annotation/json_annotation.dart';

part 'post_next_week_survey_model.g.dart';

@JsonSerializable()
class NextWeekSurveyModel {
  @JsonKey(name: "mondayDate")
  final DateTime mondayDate;

  NextWeekSurveyModel({
    required this.mondayDate,
  });

  NextWeekSurveyModel copyWith({
    DateTime? mondayDate,
  }) =>
      NextWeekSurveyModel(
        mondayDate: mondayDate ?? this.mondayDate,
      );

  factory NextWeekSurveyModel.fromJson(Map<String, dynamic> json) =>
      _$NextWeekSurveyModelFromJson(json);

  Map<String, dynamic> toJson() => _$NextWeekSurveyModelToJson(this);
}
