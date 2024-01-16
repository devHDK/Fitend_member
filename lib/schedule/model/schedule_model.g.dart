// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ScheduleData.fromJson(e as Map<String, dynamic>))
          .toList(),
      scrollIndex: json['scrollIndex'] as int?,
      isNeedMeeing: json['isNeedMeeing'] as bool?,
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'scrollIndex': instance.scrollIndex,
      'isNeedMeeing': instance.isNeedMeeing,
    };

ScheduleData _$ScheduleDataFromJson(Map<String, dynamic> json) => ScheduleData(
      startDate: DateTime.parse(json['startDate'] as String),
      schedule: json['schedule'] as List<dynamic>?,
    );

Map<String, dynamic> _$ScheduleDataToJson(ScheduleData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'schedule': instance.schedule,
    };
