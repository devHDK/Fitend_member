import 'package:fitend_member/thread/model/gallery_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_create_model.g.dart';

@JsonSerializable()
class ThreadCreateModel {
  @JsonKey(name: "trainerId")
  final int trainerId;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "content")
  final String content;
  @JsonKey(name: "gallery")
  final List<GalleryModel> gallery;

  ThreadCreateModel({
    required this.trainerId,
    required this.title,
    required this.content,
    required this.gallery,
  });

  ThreadCreateModel copyWith({
    int? trainerId,
    String? title,
    String? content,
    List<GalleryModel>? gallery,
  }) =>
      ThreadCreateModel(
        trainerId: trainerId ?? this.trainerId,
        title: title ?? this.title,
        content: content ?? this.content,
        gallery: gallery ?? this.gallery,
      );

  factory ThreadCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCreateModelToJson(this);
}
