import 'package:fitend_member/thread/model/emoji_model.dart';
import 'package:fitend_member/thread/model/gallery_model.dart';
import 'package:fitend_member/thread/model/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/thread_user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_comment_model.g.dart';

@JsonSerializable()
class ThreadCommentModel {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "threadId")
  final int threadId;
  @JsonKey(name: "trainerId")
  final int trainerId;
  @JsonKey(name: "userId")
  final int userId;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  final List<GalleryModel> gallery;
  @JsonKey(name: "user")
  ThreadUser? user;
  @JsonKey(name: "trainer")
  ThreadTrainer? trainer;
  @JsonKey(name: "emojis")
  final List<EmojiModel> emojis;
  @JsonKey(name: "createdAt")
  final String createdAt;

  ThreadCommentModel({
    required this.id,
    required this.threadId,
    required this.trainerId,
    required this.userId,
    required this.content,
    required this.gallery,
    required this.user,
    required this.trainer,
    required this.emojis,
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

  factory ThreadCommentModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCommentModelToJson(this);
}
