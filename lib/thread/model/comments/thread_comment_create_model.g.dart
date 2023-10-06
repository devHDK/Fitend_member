// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_comment_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadCommentCreateModel _$ThreadCommentCreateModelFromJson(
        Map<String, dynamic> json) =>
    ThreadCommentCreateModel(
      threadId: json['threadId'] as int?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadCommentCreateModelToJson(
        ThreadCommentCreateModel instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'content': instance.content,
      'gallery': instance.gallery,
    };
