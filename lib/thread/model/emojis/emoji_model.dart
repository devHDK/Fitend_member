import 'package:json_annotation/json_annotation.dart';

part 'emoji_model.g.dart';

@JsonSerializable()
class EmojiModel {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "emoji")
  final String emoji;
  @JsonKey(name: "userId")
  int? userId;
  @JsonKey(name: "trainerId")
  int? trainerId;

  EmojiModel({
    required this.id,
    required this.emoji,
    required this.userId,
    required this.trainerId,
  });

  EmojiModel copyWith({
    int? id,
    String? emoji,
    int? userId,
    int? trainerId,
  }) =>
      EmojiModel(
        id: id ?? this.id,
        emoji: emoji ?? this.emoji,
        userId: userId ?? this.userId,
        trainerId: trainerId ?? this.trainerId,
      );

  factory EmojiModel.fromJson(Map<String, dynamic> json) =>
      _$EmojiModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmojiModelToJson(this);
}

@JsonSerializable()
class EmojiModelFromPushData {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "emoji")
  final String emoji;
  @JsonKey(name: "userId")
  int? userId;
  @JsonKey(name: "trainerId")
  int? trainerId;
  @JsonKey(name: "threadId")
  int? threadId;
  @JsonKey(name: "commentId")
  int? commentId;

  EmojiModelFromPushData({
    required this.id,
    required this.emoji,
    this.userId,
    this.trainerId,
    this.threadId,
    this.commentId,
  });

  EmojiModelFromPushData copyWith({
    int? id,
    String? emoji,
    int? userId,
    int? trainerId,
    int? threadId,
    int? commentId,
  }) =>
      EmojiModelFromPushData(
        id: id ?? this.id,
        emoji: emoji ?? this.emoji,
        userId: userId ?? this.userId,
        trainerId: trainerId ?? this.trainerId,
        threadId: threadId ?? this.threadId,
        commentId: commentId ?? this.commentId,
      );

  factory EmojiModelFromPushData.fromJson(Map<String, dynamic> json) =>
      _$EmojiModelFromPushDataFromJson(json);

  Map<String, dynamic> toJson() => _$EmojiModelFromPushDataToJson(this);
}
