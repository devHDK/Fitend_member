// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileResponseModel _$FileResponseModelFromJson(Map<String, dynamic> json) =>
    FileResponseModel(
      path: json['path'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$FileResponseModelToJson(FileResponseModel instance) =>
    <String, dynamic>{
      'path': instance.path,
      'url': instance.url,
    };
