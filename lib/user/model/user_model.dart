import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

abstract class UserModelBase {}

class UserModelError extends UserModelBase {
  final String error;

  UserModelError({
    required this.error,
  });
}

class UserModelLoading extends UserModelBase {}

@JsonSerializable()
class UserModel extends UserModelBase {
  User user;

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
  int id;
  String email;
  String nickname;
  String phone;
  String deletedAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.phone,
    required this.deletedAt,
  });

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? phone,
    String? deletedAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        nickname: nickname ?? this.nickname,
        phone: phone ?? this.phone,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
