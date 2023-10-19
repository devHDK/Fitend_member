import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_comment_edit_model.g.dart';

@JsonSerializable()
class ThreadCommentEditModel {
  @JsonKey(name: "threadId")
  final int threadId;
  @JsonKey(name: "title")
  final String? title;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  final List<GalleryModel>? gallery;

  ThreadCommentEditModel({
    required this.threadId,
    this.title,
    required this.content,
    this.gallery,
  });

  ThreadCommentEditModel copyWith(
          {int? threadId,
          String? title,
          String? content,
          List<GalleryModel>? gallery}) =>
      ThreadCommentEditModel(
        threadId: threadId ?? this.threadId,
        title: title ?? this.title,
        content: content ?? this.content,
        gallery: gallery ?? this.gallery,
      );

  factory ThreadCommentEditModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCommentEditModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCommentEditModelToJson(this);
}
