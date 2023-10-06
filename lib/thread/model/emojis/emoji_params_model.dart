import 'package:json_annotation/json_annotation.dart';

part 'emoji_params_model.g.dart';

@JsonSerializable()
class PutEmojiParamsModel {
  @JsonKey(name: "emoji")
  final String? emoji;
  @JsonKey(name: "threadId")
  final int? threadId;
  @JsonKey(name: "commentId")
  final int? commentId;

  PutEmojiParamsModel({
    this.emoji,
    this.threadId,
    this.commentId,
  });

  PutEmojiParamsModel copyWith({
    String? emoji,
    int? threadId,
    int? commentId,
  }) =>
      PutEmojiParamsModel(
        emoji: emoji ?? this.emoji,
        threadId: threadId ?? this.threadId,
        commentId: commentId ?? this.commentId,
      );

  factory PutEmojiParamsModel.fromJson(Map<String, dynamic> json) =>
      _$PutEmojiParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PutEmojiParamsModelToJson(this);
}
