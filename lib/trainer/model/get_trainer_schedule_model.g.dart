// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_trainer_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTrainerScheduleModel _$GetTrainerScheduleModelFromJson(
        Map<String, dynamic> json) =>
    GetTrainerScheduleModel(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$GetTrainerScheduleModelToJson(
        GetTrainerScheduleModel instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };
