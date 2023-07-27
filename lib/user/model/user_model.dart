import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

abstract class UserModelBase {}

class UserModelError extends UserModelBase {
  final String error;
  final int statusCode;

  UserModelError({
    required this.error,
    required this.statusCode,
  });
}

class UserModelLoading extends UserModelBase {}

@JsonSerializable()
class UserModel extends UserModelBase {
  final User user;

  UserModel({
    required this.user,
  });

  UserModel copyWith({
    User? user,
  }) =>
      UserModel(
        user: user ?? this.user,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String nickname;
  final String? phone;
  final bool isNotification;
  final String? deletedAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.phone,
    required this.isNotification,
    this.deletedAt,
  });

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? phone,
    bool? isNotification,
    String? deletedAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        nickname: nickname ?? this.nickname,
        phone: phone ?? this.phone,
        isNotification: isNotification ?? this.isNotification,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
