// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerDetailModel _$TrainerDetailModelFromJson(Map<String, dynamic> json) =>
    TrainerDetailModel(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String,
      profileImage: json['profileImage'] as String,
      largeProfileImage: json['largeProfileImage'] as String,
      shortIntro: json['shortIntro'] as String,
      intro: json['intro'] as String,
      instagram: json['instagram'] as String,
      qualification:
          CoachingStyle.fromJson(json['qualification'] as Map<String, dynamic>),
      speciality:
          CoachingStyle.fromJson(json['speciality'] as Map<String, dynamic>),
      coachingStyle:
          CoachingStyle.fromJson(json['coachingStyle'] as Map<String, dynamic>),
      favorite:
          CoachingStyle.fromJson(json['favorite'] as Map<String, dynamic>),
      franchises: (json['franchises'] as List<dynamic>?)
          ?.map((e) => Franchise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrainerDetailModelToJson(TrainerDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'email': instance.email,
      'createdAt': instance.createdAt,
      'profileImage': instance.profileImage,
      'largeProfileImage': instance.largeProfileImage,
      'shortIntro': instance.shortIntro,
      'intro': instance.intro,
      'instagram': instance.instagram,
      'qualification': instance.qualification,
      'speciality': instance.speciality,
      'coachingStyle': instance.coachingStyle,
      'favorite': instance.favorite,
      'franchises': instance.franchises,
    };

CoachingStyle _$CoachingStyleFromJson(Map<String, dynamic> json) =>
    CoachingStyle(
      data: (json['data'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CoachingStyleToJson(CoachingStyle instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

Franchise _$FranchiseFromJson(Map<String, dynamic> json) => Franchise(
      id: json['id'] as int,
      name: json['name'] as String,
    );

Map<String, dynamic> _$FranchiseToJson(Franchise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
