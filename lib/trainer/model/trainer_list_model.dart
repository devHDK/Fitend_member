import 'package:json_annotation/json_annotation.dart';

part 'trainer_list_model.g.dart';

abstract class TrainerListModelBase {}

class TrainerListModelError extends TrainerListModelBase {
  final String message;

  TrainerListModelError({
    required this.message,
  });
}

class TrainerListModelLoading extends TrainerListModelBase {}

@JsonSerializable()
class TrainerListModel extends TrainerListModelBase {
  @JsonKey(name: "data")
  final List<TrainerInfo> data;

  TrainerListModel({
    required this.data,
  });

  TrainerListModel copyWith({
    List<TrainerInfo>? data,
  }) =>
      TrainerListModel(
        data: data ?? this.data,
      );

  factory TrainerListModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerListModelToJson(this);
}

@JsonSerializable()
class TrainerInfo {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "nickname")
  final String nickname;
  @JsonKey(name: "profileImage")
  final String profileImage;
  @JsonKey(name: "largeProfileImage")
  final String largeProfileImage;
  @JsonKey(name: "shortIntro")
  final String shortIntro;

  TrainerInfo({
    required this.id,
    required this.nickname,
    required this.profileImage,
    required this.largeProfileImage,
    required this.shortIntro,
  });

  TrainerInfo copyWith({
    int? id,
    String? nickname,
    String? profileImage,
    String? largeProfileImage,
    String? shortIntro,
  }) =>
      TrainerInfo(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        profileImage: profileImage ?? this.profileImage,
        largeProfileImage: largeProfileImage ?? this.largeProfileImage,
        shortIntro: shortIntro ?? this.shortIntro,
      );

  factory TrainerInfo.fromJson(Map<String, dynamic> json) =>
      _$TrainerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerInfoToJson(this);
}
