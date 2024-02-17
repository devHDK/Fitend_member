import 'package:json_annotation/json_annotation.dart';

part 'get_next_week_survey_model.g.dart';

@JsonSerializable()
class GetNextWeekSurveyModel {
  @JsonKey(name: "mondayDate")
  final DateTime mondayDate;

  GetNextWeekSurveyModel({
    required this.mondayDate,
  });

  GetNextWeekSurveyModel copyWith({
    DateTime? mondayDate,
  }) =>
      GetNextWeekSurveyModel(
        mondayDate: mondayDate ?? this.mondayDate,
      );

  factory GetNextWeekSurveyModel.fromJson(Map<String, dynamic> json) =>
      _$GetNextWeekSurveyModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetNextWeekSurveyModelToJson(this);
}
