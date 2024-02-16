// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_next_week_survey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextWeekSurveyModel _$NextWeekSurveyModelFromJson(Map<String, dynamic> json) =>
    NextWeekSurveyModel(
      mondayDate: DateTime.parse(json['mondayDate'] as String),
    );

Map<String, dynamic> _$NextWeekSurveyModelToJson(
        NextWeekSurveyModel instance) =>
    <String, dynamic>{
      'mondayDate': instance.mondayDate.toIso8601String(),
    };
