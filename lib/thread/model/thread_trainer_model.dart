import 'package:json_annotation/json_annotation.dart';

part 'thread_trainer_model.g.dart';

@JsonSerializable()
class ThreadTrainer {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "nickname")
  final String nickname;
  @JsonKey(name: "profileImage")
  final String profileImage;

  ThreadTrainer({
    required this.id,
    required this.nickname,
    required this.profileImage,
  });

  ThreadTrainer copyWith({
    int? id,
    String? nickname,
    String? profileImage,
  }) =>
      ThreadTrainer(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        profileImage: profileImage ?? this.profileImage,
      );

  factory ThreadTrainer.fromJson(Map<String, dynamic> json) =>
      _$ThreadTrainerFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadTrainerToJson(this);
}
