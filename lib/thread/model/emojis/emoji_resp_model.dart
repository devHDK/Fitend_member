import 'package:json_annotation/json_annotation.dart';
part 'emoji_resp_model.g.dart';

@JsonSerializable()
class EmojiRespModel {
  @JsonKey(name: "emojiId")
  final int emojiId;

  EmojiRespModel({
    required this.emojiId,
  });

  EmojiRespModel copyWith({
    int? emojiId,
  }) =>
      EmojiRespModel(
        emojiId: emojiId ?? this.emojiId,
      );

  factory EmojiRespModel.fromJson(Map<String, dynamic> json) =>
      _$EmojiRespModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmojiRespModelToJson(this);
}
