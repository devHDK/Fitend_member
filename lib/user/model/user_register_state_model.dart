import 'package:fitend_member/user/model/post_user_register_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_register_state_model.g.dart';

abstract class UserRegisterStateModelBase {}

@HiveType(typeId: 9)
@JsonSerializable()
class UserRegisterStateModel extends UserRegisterStateModelBase {
  @HiveField(1)
  @JsonKey(name: "trainerId")
  int? trainerId;
  @HiveField(3)
  @JsonKey(name: "nickname")
  String? nickname;
  @HiveField(5)
  @JsonKey(name: "password")
  String? password;
  @HiveField(7)
  @JsonKey(name: "email")
  String? email;
  @HiveField(9)
  @JsonKey(name: "phone")
  String? phone;
  @HiveField(11)
  @JsonKey(name: "birth")
  DateTime? birth;
  @HiveField(13)
  @JsonKey(name: "gender")
  String? gender;
  @HiveField(15)
  @JsonKey(name: "height")
  double? height;
  @HiveField(17)
  @JsonKey(name: "weight")
  double? weight;
  @HiveField(19)
  @JsonKey(name: "experience")
  int? experience;
  @HiveField(21)
  @JsonKey(name: "purpose")
  int? purpose;
  @HiveField(23)
  @JsonKey(name: "achievement")
  List<int>? achievement;
  @HiveField(25)
  @JsonKey(name: "obstacle")
  List<int>? obstacle;
  @HiveField(27)
  @JsonKey(name: "place")
  String? place;
  @HiveField(29)
  @JsonKey(name: "preferDays")
  List<int>? preferDays;
  @HiveField(31)
  @JsonKey(name: "step")
  int? step;
  @HiveField(33)
  @JsonKey(name: "progressStep")
  int? progressStep;

  UserRegisterStateModel(
      {this.trainerId,
      this.nickname,
      this.password,
      this.email,
      this.phone,
      this.birth,
      this.gender,
      this.height,
      this.weight,
      this.experience,
      this.purpose,
      this.achievement,
      this.obstacle,
      this.place,
      this.preferDays,
      this.step,
      this.progressStep});

  UserRegisterStateModel copyWith({
    int? trainerId,
    String? nickname,
    String? password,
    String? email,
    String? phone,
    DateTime? birth,
    String? gender,
    double? height,
    double? weight,
    int? experience,
    int? purpose,
    List<int>? achievement,
    List<int>? obstacle,
    String? place,
    List<int>? preferDays,
    int? step,
    int? progressStep,
  }) =>
      UserRegisterStateModel(
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
        step: step ?? this.step,
        progressStep: progressStep ?? this.progressStep,
      );

  factory UserRegisterStateModel.fromJson(Map<String, dynamic> json) =>
      _$UserRegisterStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegisterStateModelToJson(this);

  PostUserRegisterModel stateModelToPostModel(
      UserRegisterStateModel stateModel) {
    return PostUserRegisterModel(
      trainerId: stateModel.trainerId,
      phone: stateModel.phone,
      nickname: stateModel.nickname,
      email: stateModel.email,
      password: stateModel.password,
      gender: stateModel.gender,
      height: stateModel.height,
      weight: stateModel.weight,
      birth: stateModel.birth,
      experience: stateModel.experience,
      purpose: stateModel.purpose,
      achievement: stateModel.achievement,
      obstacle: stateModel.obstacle,
      place: stateModel.place,
      preferDays: stateModel.preferDays,
    );
  }
}
