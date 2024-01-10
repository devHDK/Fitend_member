import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_user_register_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 9)
class PostUserRegisterModel {
  @HiveField(1)
  int? trainerId;
  @HiveField(2)
  String? nickname;
  @HiveField(3)
  String? password;
  @HiveField(4)
  String? email;
  @HiveField(5)
  String? phone;
  @HiveField(6)
  DateTime? birth;
  @HiveField(7)
  String? gender;
  @HiveField(8)
  int? height;
  @HiveField(9)
  int? weight;
  @HiveField(10)
  int? experience;
  @HiveField(11)
  int? purpose;
  @HiveField(12)
  List<int>? achievement;
  @HiveField(13)
  List<int>? obstacle;
  @HiveField(14)
  String? place;
  @HiveField(15)
  List<int>? preferDays;
  @HiveField(16)
  String? step;

  PostUserRegisterModel({
    this.trainerId,
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
    String? step,
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
        step: step ?? this.step,
      );
}
