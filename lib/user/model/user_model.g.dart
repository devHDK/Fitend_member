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
          .map((e) => TrainerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeTickets: (json['activeTickets'] as List<dynamic>?)
          ?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastTrainers: (json['lastTrainers'] as List<dynamic>)
          .map((e) => TrainerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastTickets: (json['lastTickets'] as List<dynamic>?)
          ?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      isWorkoutSurvey: json['isWorkoutSurvey'] as bool?,
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
      'weight': instance.weight,
      'height': instance.height,
      'activeTrainers': instance.activeTrainers,
      'activeTickets': instance.activeTickets,
      'lastTrainers': instance.lastTrainers,
      'lastTickets': instance.lastTickets,
      'isWorkoutSurvey': instance.isWorkoutSurvey,
    };

TrainerInfo _$TrainerInfoFromJson(Map<String, dynamic> json) => TrainerInfo(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String,
      workStartTime: json['workStartTime'] as String,
      workEndTime: json['workEndTime'] as String,
    );

Map<String, dynamic> _$TrainerInfoToJson(TrainerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
      'workStartTime': instance.workStartTime,
      'workEndTime': instance.workEndTime,
    };
