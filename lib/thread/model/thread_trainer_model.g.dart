// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_trainer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadTrainer _$ThreadTrainerFromJson(Map<String, dynamic> json) =>
    ThreadTrainer(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String,
    );

Map<String, dynamic> _$ThreadTrainerToJson(ThreadTrainer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
    };
