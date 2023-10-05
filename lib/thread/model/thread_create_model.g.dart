// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadCreate _$ThreadCreateFromJson(Map<String, dynamic> json) => ThreadCreate(
      trainerId: json['trainerId'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>)
          .map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadCreateToJson(ThreadCreate instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'title': instance.title,
      'content': instance.content,
      'gallery': instance.gallery,
    };
