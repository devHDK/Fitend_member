import 'package:json_annotation/json_annotation.dart';

part 'post_user_register_model.g.dart';

@JsonSerializable()
class PostUserRegisterModel {
  @JsonKey(name: "trainerId")
  final int trainerId;
  @JsonKey(name: "nickname")
  final String nickname;
  @JsonKey(name: "password")
  final String password;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "phone")
  final String phone;
  @JsonKey(name: "birth")
  final DateTime birth;
  @JsonKey(name: "gender")
  final String gender;
  @JsonKey(name: "height")
  final int height;
  @JsonKey(name: "weight")
  final int weight;
  @JsonKey(name: "experience")
  final int experience;
  @JsonKey(name: "purpose")
  final int purpose;
  @JsonKey(name: "achievement")
  final List<int> achievement;
  @JsonKey(name: "obstacle")
  final List<int> obstacle;
  @JsonKey(name: "place")
  final String place;
  @JsonKey(name: "preferDays")
  final List<int> preferDays;

  PostUserRegisterModel({
    required this.trainerId,
    required this.nickname,
    required this.password,
    required this.email,
    required this.phone,
    required this.birth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.experience,
    required this.purpose,
    required this.achievement,
    required this.obstacle,
    required this.place,
    required this.preferDays,
  });

  PostUserRegisterModel copyWith({
    int? trainerId,
    String? nickname,
    String? password,
    String? email,
    String? phone,
    DateTime? birth,
    String? gender,
    int? height,
    int? weight,
    int? experience,
    int? purpose,
    List<int>? achievement,
    List<int>? obstacle,
    String? place,
    List<int>? preferDays,
  }) =>
      PostUserRegisterModel(
        trainerId: trainerId ?? this.trainerId,
        nickname: nickname ?? this.nickname,
        password: password ?? this.password,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        birth: birth ?? this.birth,
        gender: gender ?? this.gender,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        experience: experience ?? this.experience,
        purpose: purpose ?? this.purpose,
        achievement: achievement ?? this.achievement,
        obstacle: obstacle ?? this.obstacle,
        place: place ?? this.place,
        preferDays: preferDays ?? this.preferDays,
      );

  factory PostUserRegisterModel.fromJson(Map<String, dynamic> json) =>
      _$PostUserRegisterModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostUserRegisterModelToJson(this);
}
