// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_comment_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadCommentListModel _$ThreadCommentListModelFromJson(
        Map<String, dynamic> json) =>
    ThreadCommentListModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ThreadCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadCommentListModelToJson(
        ThreadCommentListModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
