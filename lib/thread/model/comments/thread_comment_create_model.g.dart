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

ThreadCommentCreateTempModel _$ThreadCommentCreateTempModelFromJson(
        Map<String, dynamic> json) =>
    ThreadCommentCreateTempModel(
      threadId: json['threadId'] as int,
      content: json['content'] as String,
      assetsPaths:
          (json['gallery'] as List<dynamic>).map((e) => e as String).toList(),
      emojis: (json['emojis'] as List<dynamic>)
          .map((e) => EmojiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isLoading: json['isLoading'] as bool,
      isUploading: json['isUploading'] as bool,
      doneCount: json['doneCount'] as int,
      totalCount: json['totalCount'] as int,
    );

Map<String, dynamic> _$ThreadCommentCreateTempModelToJson(
        ThreadCommentCreateTempModel instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'content': instance.content,
      'gallery': instance.assetsPaths,
      'emojis': instance.emojis,
      'isLoading': instance.isLoading,
      'isUploading': instance.isUploading,
      'doneCount': instance.doneCount,
      'totalCount': instance.totalCount,
    };
