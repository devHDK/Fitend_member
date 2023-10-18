// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_edit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadEditModel _$ThreadEditModelFromJson(Map<String, dynamic> json) =>
    ThreadEditModel(
      threadId: json['threadId'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadEditModelToJson(ThreadEditModel instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'title': instance.title,
      'content': instance.content,
      'gallery': instance.gallery,
    };
