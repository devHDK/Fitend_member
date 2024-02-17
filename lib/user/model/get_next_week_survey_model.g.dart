// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_next_week_survey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetNextWeekSurveyModel _$GetNextWeekSurveyModelFromJson(
        Map<String, dynamic> json) =>
    GetNextWeekSurveyModel(
      mondayDate: DateTime.parse(json['mondayDate'] as String),
    );

Map<String, dynamic> _$GetNextWeekSurveyModelToJson(
        GetNextWeekSurveyModel instance) =>
    <String, dynamic>{
      'mondayDate': instance.mondayDate.toIso8601String(),
    };
