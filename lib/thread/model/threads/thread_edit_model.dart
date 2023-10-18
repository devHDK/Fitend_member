import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_edit_model.g.dart';

@JsonSerializable()
class ThreadEditModel {
  @JsonKey(name: "threadId")
  final int threadId;
  @JsonKey(name: "title")
  final String? title;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  final List<GalleryModel>? gallery;

  ThreadEditModel({
    required this.threadId,
    this.title,
    required this.content,
    this.gallery,
  });

  ThreadEditModel copyWith({
    int? threadId,
    String? title,
    String? content,
  }) =>
      ThreadEditModel(
        threadId: threadId ?? this.threadId,
        title: title ?? this.title,
        content: content ?? this.content,
      );

  factory ThreadEditModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadEditModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadEditModelToJson(this);
}
