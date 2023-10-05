// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileRequestModel _$FileRequestModelFromJson(Map<String, dynamic> json) =>
    FileRequestModel(
      type: json['type'] as String,
      mimeType: json['mimeType'] as String,
    );

Map<String, dynamic> _$FileRequestModelToJson(FileRequestModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'mimeType': instance.mimeType,
    };
