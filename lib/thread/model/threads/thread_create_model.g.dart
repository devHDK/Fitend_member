// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadCreateModel _$ThreadCreateModelFromJson(Map<String, dynamic> json) =>
    ThreadCreateModel(
      trainerId: json['trainerId'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadCreateModelToJson(ThreadCreateModel instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'title': instance.title,
      'content': instance.content,
      'gallery': instance.gallery,
    };

ThreadCreateTempModel _$ThreadCreateTempModelFromJson(
        Map<String, dynamic> json) =>
    ThreadCreateTempModel(
      trainerId: json['trainerId'] as int?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      assetsPaths:
          (json['assets'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isLoading: json['isLoading'] as bool,
      isUploading: json['isUploading'] as bool,
      doneCount: json['doneCount'] as int,
      totalCount: json['totalCount'] as int,
    );

Map<String, dynamic> _$ThreadCreateTempModelToJson(
        ThreadCreateTempModel instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'title': instance.title,
      'content': instance.content,
      'assets': instance.assetsPaths,
      'isLoading': instance.isLoading,
      'isUploading': instance.isUploading,
      'doneCount': instance.doneCount,
      'totalCount': instance.totalCount,
    };
