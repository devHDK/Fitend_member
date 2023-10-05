import 'package:fitend_member/thread/model/gallery_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_comment_create_model.g.dart';

@JsonSerializable()
class ThreadCommentCreateModel {
  @JsonKey(name: "threadId")
  int? threadId;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  List<GalleryModel>? gallery;

  ThreadCommentCreateModel({
    required this.threadId,
    required this.content,
    required this.gallery,
  });

  ThreadCommentCreateModel copyWith({
    int? threadId,
    String? content,
    List<GalleryModel>? gallery,
  }) =>
      ThreadCommentCreateModel(
        threadId: threadId ?? this.threadId,
        content: content ?? this.content,
        gallery: gallery ?? this.gallery,
      );

  factory ThreadCommentCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCommentCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCommentCreateModelToJson(this);
}
