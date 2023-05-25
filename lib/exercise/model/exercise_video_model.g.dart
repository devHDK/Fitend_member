// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseVideo _$ExerciseVideoFromJson(Map<String, dynamic> json) =>
    ExerciseVideo(
      url: json['url'] as String,
      index: json['index'] as int,
      thumbnail: json['thumbnail'] as String,
    );

Map<String, dynamic> _$ExerciseVideoToJson(ExerciseVideo instance) =>
    <String, dynamic>{
      'url': instance.url,
      'index': instance.index,
      'thumbnail': instance.thumbnail,
    };
