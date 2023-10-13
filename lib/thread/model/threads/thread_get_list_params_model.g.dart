// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_get_list_params_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadGetListParamsModel _$ThreadGetListParamsModelFromJson(
        Map<String, dynamic> json) =>
    ThreadGetListParamsModel(
      start: json['start'] as int,
      perPage: json['perPage'] as int,
    );

Map<String, dynamic> _$ThreadGetListParamsModelToJson(
        ThreadGetListParamsModel instance) =>
    <String, dynamic>{
      'start': instance.start,
      'perPage': instance.perPage,
    };
