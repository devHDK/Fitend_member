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
      isNotification: json['isNotification'] as bool?,
      deletedAt: json['deletedAt'] as String?,
      activeTrainers: (json['activeTrainers'] as List<dynamic>)
          .map((e) => ActiveTrainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'phone': instance.phone,
      'isNotification': instance.isNotification,
      'deletedAt': instance.deletedAt,
      'activeTrainers': instance.activeTrainers,
    };

ActiveTrainer _$ActiveTrainerFromJson(Map<String, dynamic> json) =>
    ActiveTrainer(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
    );

Map<String, dynamic> _$ActiveTrainerToJson(ActiveTrainer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
    };
