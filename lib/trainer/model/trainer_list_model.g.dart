// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerListModel _$TrainerListModelFromJson(Map<String, dynamic> json) =>
    TrainerListModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => TrainerInfomation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrainerListModelToJson(TrainerListModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

TrainerInfomation _$TrainerInfomationFromJson(Map<String, dynamic> json) =>
    TrainerInfomation(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String,
      largeProfileImage: json['largeProfileImage'] as String,
      shortIntro: json['shortIntro'] as String,
    );

Map<String, dynamic> _$TrainerInfomationToJson(TrainerInfomation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
      'largeProfileImage': instance.largeProfileImage,
      'shortIntro': instance.shortIntro,
    };
