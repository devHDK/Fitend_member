import 'package:json_annotation/json_annotation.dart';

part 'trainer_detail_model.g.dart';

abstract class TrainerDetailModelBase {}

class TrainerDetailModelError extends TrainerDetailModelBase {
  final String message;

  TrainerDetailModelError({
    required this.message,
  });
}

class TrainerDetailModelLoading extends TrainerDetailModelBase {}

@JsonSerializable()
class TrainerDetailModel extends TrainerDetailModelBase {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "nickname")
  final String nickname;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "createdAt")
  final String createdAt;
  @JsonKey(name: "profileImage")
  final String profileImage;
  @JsonKey(name: "largeProfileImage")
  final String largeProfileImage;
  @JsonKey(name: "shortIntro")
  final String shortIntro;
  @JsonKey(name: "intro")
  final String intro;
  @JsonKey(name: "instagram")
  final String instagram;
  @JsonKey(name: "qualification")
  final CoachingStyle qualification;
  @JsonKey(name: "speciality")
  final CoachingStyle speciality;
  @JsonKey(name: "coachingStyle")
  final CoachingStyle coachingStyle;
  @JsonKey(name: "favorite")
  final CoachingStyle favorite;
  @JsonKey(name: "franchises")
  final List<Franchise>? franchises;

  TrainerDetailModel({
    required this.id,
    required this.nickname,
    required this.email,
    required this.createdAt,
    required this.profileImage,
    required this.largeProfileImage,
    required this.shortIntro,
    required this.intro,
    required this.instagram,
    required this.qualification,
    required this.speciality,
    required this.coachingStyle,
    required this.favorite,
    this.franchises,
  });

  TrainerDetailModel copyWith({
    int? id,
    String? nickname,
    String? email,
    String? createdAt,
    String? profileImage,
    String? largeProfileImage,
    String? shortIntro,
    String? intro,
    String? instagram,
    CoachingStyle? qualification,
    CoachingStyle? speciality,
    CoachingStyle? coachingStyle,
    CoachingStyle? favorite,
    List<Franchise>? franchises,
  }) =>
      TrainerDetailModel(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
        profileImage: profileImage ?? this.profileImage,
        largeProfileImage: largeProfileImage ?? this.largeProfileImage,
        shortIntro: shortIntro ?? this.shortIntro,
        intro: intro ?? this.intro,
        instagram: instagram ?? this.instagram,
        qualification: qualification ?? this.qualification,
        speciality: speciality ?? this.speciality,
        coachingStyle: coachingStyle ?? this.coachingStyle,
        favorite: favorite ?? this.favorite,
        franchises: franchises ?? this.franchises,
      );

  factory TrainerDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerDetailModelToJson(this);
}

@JsonSerializable()
class CoachingStyle {
  @JsonKey(name: "data")
  final List<String> data;

  CoachingStyle({
    required this.data,
  });

  CoachingStyle copyWith({
    List<String>? data,
  }) =>
      CoachingStyle(
        data: data ?? this.data,
      );

  factory CoachingStyle.fromJson(Map<String, dynamic> json) =>
      _$CoachingStyleFromJson(json);

  Map<String, dynamic> toJson() => _$CoachingStyleToJson(this);
}

@JsonSerializable()
class Franchise {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;

  Franchise({
    required this.id,
    required this.name,
  });

  Franchise copyWith({
    int? id,
    String? name,
  }) =>
      Franchise(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory Franchise.fromJson(Map<String, dynamic> json) =>
      _$FranchiseFromJson(json);

  Map<String, dynamic> toJson() => _$FranchiseToJson(this);
}
