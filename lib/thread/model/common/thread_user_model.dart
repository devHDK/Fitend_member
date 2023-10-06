import 'package:json_annotation/json_annotation.dart';

part 'thread_user_model.g.dart';

@JsonSerializable()
class ThreadUser {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "nickname")
  final String nickname;
  @JsonKey(name: "gender")
  final String gender;

  ThreadUser({
    required this.id,
    required this.nickname,
    required this.gender,
  });

  ThreadUser copyWith({
    int? id,
    String? nickname,
    String? gender,
  }) =>
      ThreadUser(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        gender: gender ?? this.gender,
      );

  factory ThreadUser.fromJson(Map<String, dynamic> json) =>
      _$ThreadUserFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadUserToJson(this);
}
