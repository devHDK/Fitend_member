// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadListModel _$ThreadListModelFromJson(Map<String, dynamic> json) =>
    ThreadListModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ThreadModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$ThreadListModelToJson(ThreadListModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
    };
