import 'package:fitend_member/thread/model/comments/thread_comment_model.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/common/thread_workout_info_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_model.g.dart';

abstract class ThreadModelBase {}

class ThreadModelError extends ThreadModelBase {
  final String message;

  ThreadModelError({
    required this.message,
  });
}

class ThreadModelLoading extends ThreadModelBase {}

@JsonSerializable()
class ThreadModel extends ThreadModelBase {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "writerType")
  final String writerType;
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  List<GalleryModel>? gallery;
  @JsonKey(name: "workoutInfo")
  ThreadWorkoutInfo? workoutInfo;
  @JsonKey(name: "user")
  final ThreadUser user;
  @JsonKey(name: "trainer")
  final ThreadTrainer trainer;
  @JsonKey(name: "emojis")
  List<EmojiModel>? emojis;
  @JsonKey(name: "userCommentCount")
  int? userCommentCount;
  @JsonKey(name: "trainerCommentCount")
  int? trainerCommentCount;
  @JsonKey(name: "createdAt")
  final String createdAt;
  @JsonKey(name: "comments")
  List<ThreadCommentModel>? comments;

  ThreadModel({
    required this.id,
    required this.writerType,
    required this.type,
    required this.title,
    required this.content,
    required this.gallery,
    required this.workoutInfo,
    required this.user,
    required this.trainer,
    required this.emojis,
    this.userCommentCount,
    this.trainerCommentCount,
    required this.createdAt,
    this.comments,
  });

  ThreadModel copyWith({
    int? id,
    String? writerType,
    String? type,
    String? title,
    String? content,
    List<GalleryModel>? gallery,
    ThreadWorkoutInfo? workoutInfo,
    ThreadUser? user,
    ThreadTrainer? trainer,
    List<EmojiModel>? emojis,
    int? userCommentCount,
    int? trainerCommentCount,
    String? createdAt,
    List<ThreadCommentModel>? comments,
  }) =>
      ThreadModel(
        id: id ?? this.id,
        writerType: writerType ?? this.writerType,
        type: type ?? this.type,
        title: title ?? this.title,
        content: content ?? this.content,
        gallery: gallery ?? this.gallery,
        workoutInfo: workoutInfo ?? this.workoutInfo,
        user: user ?? this.user,
        trainer: trainer ?? this.trainer,
        emojis: emojis ?? this.emojis,
        userCommentCount: userCommentCount ?? this.userCommentCount,
        trainerCommentCount: trainerCommentCount ?? this.trainerCommentCount,
        createdAt: createdAt ?? this.createdAt,
        comments: comments ?? this.comments,
      );

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    json['emojis'] = json['emojis'] ?? [];
    json['gallery!'] = json['gallery!'] ?? [];
    return _$ThreadModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ThreadModelToJson(this);
}
