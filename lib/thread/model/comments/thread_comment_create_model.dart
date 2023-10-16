import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
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
    this.gallery,
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

@JsonSerializable()
class ThreadCommentCreateTempModel {
  @JsonKey(name: "threadId")
  int threadId;
  @JsonKey(name: "content")
  String content;
  @JsonKey(name: "gallery")
  List<String> assetsPaths;
  @JsonKey(name: "emojis")
  List<EmojiModel> emojis;
  @JsonKey(name: "isLoading")
  bool isLoading;
  @JsonKey(name: "isUploading")
  bool isUploading;
  int doneCount;
  int totalCount;

  ThreadCommentCreateTempModel({
    required this.threadId,
    required this.content,
    required this.assetsPaths,
    required this.emojis,
    required this.isLoading,
    required this.isUploading,
    required this.doneCount,
    required this.totalCount,
  });

  ThreadCommentCreateTempModel copyWith({
    int? threadId,
    String? content,
    List<String>? assetPaths,
    List<EmojiModel>? emojis,
    bool? isLoading,
    bool? isUploading,
    int? doneCount,
    int? totalCount,
  }) =>
      ThreadCommentCreateTempModel(
        threadId: threadId ?? this.threadId,
        content: content ?? this.content,
        assetsPaths: assetPaths ?? assetsPaths,
        emojis: emojis ?? this.emojis,
        isLoading: isLoading ?? this.isLoading,
        isUploading: isUploading ?? this.isUploading,
        doneCount: doneCount ?? this.doneCount,
        totalCount: totalCount ?? this.totalCount,
      );

  factory ThreadCommentCreateTempModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCommentCreateTempModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCommentCreateTempModelToJson(this);
}
