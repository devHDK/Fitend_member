import 'package:fitend_member/thread/model/gallery_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_create_model.g.dart';

@JsonSerializable()
class ThreadCreate {
  @JsonKey(name: "trainerId")
  final int trainerId;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  final List<GalleryModel> gallery;

  ThreadCreate({
    required this.trainerId,
    required this.title,
    required this.content,
    required this.gallery,
  });

  ThreadCreate copyWith({
    int? trainerId,
    String? title,
    String? content,
    List<GalleryModel>? gallery,
  }) =>
      ThreadCreate(
        trainerId: trainerId ?? this.trainerId,
        title: title ?? this.title,
        content: content ?? this.content,
        gallery: gallery ?? this.gallery,
      );

  factory ThreadCreate.fromJson(Map<String, dynamic> json) =>
      _$ThreadCreateFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCreateToJson(this);
}
