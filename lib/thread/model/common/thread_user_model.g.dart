// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadUser _$ThreadUserFromJson(Map<String, dynamic> json) => ThreadUser(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$ThreadUserToJson(ThreadUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'gender': instance.gender,
    };
