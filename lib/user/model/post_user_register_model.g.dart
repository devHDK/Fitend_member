// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_user_register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostUserRegisterModel _$PostUserRegisterModelFromJson(
        Map<String, dynamic> json) =>
    PostUserRegisterModel(
      trainerId: json['trainerId'] as int?,
      nickname: json['nickname'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      birth: json['birth'] == null
          ? null
          : DateTime.parse(json['birth'] as String),
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      experience: json['experience'] as int?,
      purpose: json['purpose'] as int?,
      achievement: (json['achievement'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      obstacle:
          (json['obstacle'] as List<dynamic>?)?.map((e) => e as int).toList(),
      place: json['place'] as String?,
      preferDays:
          (json['preferDays'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$PostUserRegisterModelToJson(
        PostUserRegisterModel instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'nickname': instance.nickname,
      'password': instance.password,
      'email': instance.email,
      'phone': instance.phone,
      'birth': instance.birth?.toIso8601String(),
      'gender': instance.gender,
      'height': instance.height,
      'weight': instance.weight,
      'experience': instance.experience,
      'purpose': instance.purpose,
      'achievement': instance.achievement,
      'obstacle': instance.obstacle,
      'place': instance.place,
      'preferDays': instance.preferDays,
    };
