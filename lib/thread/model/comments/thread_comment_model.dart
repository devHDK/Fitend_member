import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_comment_model.g.dart';

@JsonSerializable()
class ThreadCommentModel {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "threadId")
  final int threadId;
  @JsonKey(name: "trainerId")
  int? trainerId;
  @JsonKey(name: "userId")
  int? userId;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  List<GalleryModel>? gallery;
  @JsonKey(name: "user")
  ThreadUser? user;
  @JsonKey(name: "trainer")
  ThreadTrainer? trainer;
  @JsonKey(name: "emojis")
  List<EmojiModel>? emojis;
  @JsonKey(name: "createdAt")
  final String createdAt;

  ThreadCommentModel({
    required this.id,
    required this.threadId,
    this.trainerId,
    this.userId,
    required this.content,
    this.gallery,
    this.user,
    this.trainer,
    this.emojis,
    required this.createdAt,
  });

  ThreadCommentModel copyWith({
    int? id,
    int? threadId,
    int? trainerId,
    int? userId,
    String? content,
    List<GalleryModel>? gallery,
    ThreadUser? user,
    ThreadTrainer? trainer,
    List<EmojiModel>? emojis,
    String? createdAt,
  }) =>
      ThreadCommentModel(
        id: id ?? this.id,
        threadId: threadId ?? this.threadId,
        trainerId: trainerId ?? this.trainerId,
        userId: userId ?? this.userId,
        content: content ?? this.content,
        gallery: gallery ?? this.gallery,
        user: user ?? this.user,
        trainer: trainer ?? this.trainer,
        emojis: emojis ?? this.emojis,
        createdAt: createdAt ?? this.createdAt,
      );

  factory ThreadCommentModel.fromJson(Map<String, dynamic> json) {
    json['emojis'] = json['emojis'] ?? [];
    json['gallery'] = json['gallery'] ?? [];
    return _$ThreadCommentModelFromJson(json);
  }
  Map<String, dynamic> toJson() => _$ThreadCommentModelToJson(this);
}
