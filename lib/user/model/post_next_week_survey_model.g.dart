// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_next_week_survey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostNextWeekSurveyModel _$PostNextWeekSurveyModelFromJson(
        Map<String, dynamic> json) =>
    PostNextWeekSurveyModel(
      mondayDate: DateTime.parse(json['mondayDate'] as String),
      selectedDates: (json['selectedDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      noSchedule: json['noSchedule'] as bool,
    );

Map<String, dynamic> _$PostNextWeekSurveyModelToJson(
        PostNextWeekSurveyModel instance) =>
    <String, dynamic>{
      'mondayDate': instance.mondayDate.toIso8601String(),
      'selectedDates':
          instance.selectedDates?.map((e) => e.toIso8601String()).toList(),
      'noSchedule': instance.noSchedule,
    };
