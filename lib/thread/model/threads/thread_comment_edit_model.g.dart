// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_comment_edit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadCommentEditModel _$ThreadCommentEditModelFromJson(
        Map<String, dynamic> json) =>
    ThreadCommentEditModel(
      threadId: json['threadId'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadCommentEditModelToJson(
        ThreadCommentEditModel instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'title': instance.title,
      'content': instance.content,
      'gallery': instance.gallery,
    };
