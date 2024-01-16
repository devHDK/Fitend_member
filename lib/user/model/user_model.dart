import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
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
  @JsonKey(name: "gender")
  final String gender;
  @JsonKey(name: "isNotification")
  final bool? isNotification;
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @JsonKey(name: "deletedAt")
  final String? deletedAt;
  @JsonKey(name: "weight")
  final double? weight;
  @JsonKey(name: "height")
  final double? height;
  @JsonKey(name: "activeTrainers")
  final List<TrainerInfo> activeTrainers;
  @JsonKey(name: "activeTickets")
  List<TicketModel>? activeTickets;
  @JsonKey(name: "lastTrainers")
  final List<TrainerInfo> lastTrainers;
  @JsonKey(name: "lastTickets")
  List<TicketModel>? lastTickets;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.phone,
    required this.gender,
    required this.isNotification,
    required this.createdAt,
    required this.deletedAt,
    required this.activeTrainers,
    this.activeTickets,
    required this.lastTrainers,
    this.lastTickets,
    this.weight,
    this.height,
  });

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? phone,
    String? gender,
    bool? isNotification,
    String? createdAt,
    String? deletedAt,
    double? weight,
    double? height,
    List<TrainerInfo>? activeTrainers,
    List<TicketModel>? activeTickets,
    List<TrainerInfo>? lastTrainers,
    List<TicketModel>? lastTickets,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        nickname: nickname ?? this.nickname,
        phone: phone ?? this.phone,
        gender: gender ?? this.gender,
        isNotification: isNotification ?? this.isNotification,
        deletedAt: deletedAt ?? this.deletedAt,
        weight: weight ?? this.weight,
        height: height ?? this.height,
        createdAt: createdAt ?? this.createdAt,
        activeTrainers: activeTrainers ?? this.activeTrainers,
        activeTickets: activeTickets ?? this.activeTickets,
        lastTrainers: lastTrainers ?? this.lastTrainers,
        lastTickets: lastTickets ?? this.lastTickets,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class TrainerInfo extends ThreadTrainer {
  @JsonKey(name: "workStartTime")
  final String workStartTime;
  @JsonKey(name: "workEndTime")
  final String workEndTime;

  TrainerInfo({
    required super.id,
    required super.nickname,
    required super.profileImage,
    required this.workStartTime,
    required this.workEndTime,
  });

  @override
  TrainerInfo copyWith({
    int? id,
    String? nickname,
    String? profileImage,
    String? workStartTime,
    String? workEndTime,
  }) =>
      TrainerInfo(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        profileImage: profileImage ?? this.profileImage,
        workStartTime: workStartTime ?? this.workStartTime,
        workEndTime: workEndTime ?? this.workEndTime,
      );

  factory TrainerInfo.fromJson(Map<String, dynamic> json) =>
      _$TrainerInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainerInfoToJson(this);
}
