// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryModel _$GalleryModelFromJson(Map<String, dynamic> json) => GalleryModel(
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$GalleryModelToJson(GalleryModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'thumbnail': instance.thumbnail,
    };
