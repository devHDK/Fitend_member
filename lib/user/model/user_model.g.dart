// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      phone: json['phone'] as String?,
      gender: json['gender'] as String,
      isNotification: json['isNotification'] as bool?,
      createdAt: json['createdAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
      activeTrainers: (json['activeTrainers'] as List<dynamic>)
          .map((e) => ThreadTrainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'phone': instance.phone,
      'gender': instance.gender,
      'isNotification': instance.isNotification,
      'createdAt': instance.createdAt,
      'deletedAt': instance.deletedAt,
      'activeTrainers': instance.activeTrainers,
    };
