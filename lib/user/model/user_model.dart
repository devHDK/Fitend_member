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
  @JsonKey(name: "user")
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

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "nickname")
  final String nickname;
  @JsonKey(name: "phone")
  final String? phone;
  @JsonKey(name: "isNotification")
  final bool? isNotification;
  @JsonKey(name: "deletedAt")
  final String? deletedAt;
  @JsonKey(name: "activeTrainers")
  final List<ActiveTrainer> activeTrainers;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.phone,
    required this.isNotification,
    required this.deletedAt,
    required this.activeTrainers,
  });

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? phone,
    bool? isNotification,
    String? deletedAt,
    List<ActiveTrainer>? activeTrainers,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        nickname: nickname ?? this.nickname,
        phone: phone ?? this.phone,
        isNotification: isNotification ?? this.isNotification,
        deletedAt: deletedAt ?? this.deletedAt,
        activeTrainers: activeTrainers ?? this.activeTrainers,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class ActiveTrainer {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "nickname")
  final String nickname;

  ActiveTrainer({
    required this.id,
    required this.nickname,
  });

  ActiveTrainer copyWith({
    int? id,
    String? nickname,
  }) =>
      ActiveTrainer(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
      );

  factory ActiveTrainer.fromJson(Map<String, dynamic> json) =>
      _$ActiveTrainerFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTrainerToJson(this);
}
