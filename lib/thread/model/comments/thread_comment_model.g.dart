// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadCommentModel _$ThreadCommentModelFromJson(Map<String, dynamic> json) =>
    ThreadCommentModel(
      id: json['id'] as int,
      threadId: json['threadId'] as int,
      trainerId: json['trainerId'] as int?,
      userId: json['userId'] as int?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] == null
          ? null
          : ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      trainer: json['trainer'] == null
          ? null
          : ThreadTrainer.fromJson(json['trainer'] as Map<String, dynamic>),
      emojis: (json['emojis'] as List<dynamic>?)
          ?.map((e) => EmojiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ThreadCommentModelToJson(ThreadCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'trainerId': instance.trainerId,
      'userId': instance.userId,
      'content': instance.content,
      'gallery': instance.gallery,
      'user': instance.user,
      'trainer': instance.trainer,
      'emojis': instance.emojis,
      'createdAt': instance.createdAt,
    };
