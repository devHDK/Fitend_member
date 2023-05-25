// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setInfo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetInfo _$SetInfoFromJson(Map<String, dynamic> json) => SetInfo(
      index: json['index'] as int,
      reps: json['reps'] as int?,
      weight: json['weight'] as int?,
      seconds: json['seconds'] as int?,
    );

Map<String, dynamic> _$SetInfoToJson(SetInfo instance) => <String, dynamic>{
      'index': instance.index,
      'reps': instance.reps,
      'weight': instance.weight,
      'seconds': instance.seconds,
    };
