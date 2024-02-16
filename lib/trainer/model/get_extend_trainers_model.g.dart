// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_extend_trainers_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExtendTrainersModel _$GetExtendTrainersModelFromJson(
        Map<String, dynamic> json) =>
    GetExtendTrainersModel(
      search: json['search'] as String?,
      start: json['start'] as int,
      perPage: json['perPage'] as int,
    );

Map<String, dynamic> _$GetExtendTrainersModelToJson(
        GetExtendTrainersModel instance) =>
    <String, dynamic>{
      'search': instance.search,
      'start': instance.start,
      'perPage': instance.perPage,
    };
