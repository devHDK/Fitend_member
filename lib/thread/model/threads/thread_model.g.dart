// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadModel _$ThreadModelFromJson(Map<String, dynamic> json) => ThreadModel(
      id: json['id'] as int,
      writerType: json['writerType'] as String,
      type: json['type'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      workoutInfo: json['workoutInfo'] == null
          ? null
          : ThreadWorkoutInfo.fromJson(
              json['workoutInfo'] as Map<String, dynamic>),
      user: ThreadUser.fromJson(json['user'] as Map<String, dynamic>),
      trainer: ThreadTrainer.fromJson(json['trainer'] as Map<String, dynamic>),
      emojis: (json['emojis'] as List<dynamic>?)
          ?.map((e) => EmojiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      commentCount: json['commentCount'] as int?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ThreadModelToJson(ThreadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'writerType': instance.writerType,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'gallery': instance.gallery,
      'workoutInfo': instance.workoutInfo,
      'user': instance.user,
      'trainer': instance.trainer,
      'emojis': instance.emojis,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt,
    };
