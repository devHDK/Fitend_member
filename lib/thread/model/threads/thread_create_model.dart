import 'package:fitend_member/thread/model/common/gallery_model.dart';
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
  @JsonKey(name: "isMeetingThread")
  bool? isMeetingThread;
  @JsonKey(name: "isChangeDateThread")
  bool? isChangeDateThread;
  @JsonKey(name: "gallery")
  List<GalleryModel>? gallery;

  ThreadCreateModel({
    required this.trainerId,
    this.title,
    this.isMeetingThread,
    this.isChangeDateThread,
    required this.content,
    this.gallery,
  });

  ThreadCreateModel copyWith({
    int? trainerId,
    String? title,
    bool? isMeetingThread,
    bool? isChangeDateThread,
    String? content,
    List<GalleryModel>? gallery,
  }) =>
      ThreadCreateModel(
        trainerId: trainerId ?? this.trainerId,
        title: title ?? this.title,
        content: content ?? this.content,
        isMeetingThread: isMeetingThread ?? this.isMeetingThread,
        isChangeDateThread: isChangeDateThread ?? this.isChangeDateThread,
        gallery: gallery ?? this.gallery,
      );

  factory ThreadCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCreateModelToJson(this);
}

@JsonSerializable()
class ThreadCreateTempModel {
  @JsonKey(name: "trainerId")
  int? trainerId;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "content")
  String content;
  @JsonKey(name: "assetsPaths")
  List<String>? assetsPaths;
  @JsonKey(name: "isLoading")
  bool isLoading;
  @JsonKey(name: "isUploading")
  bool isUploading;
  @JsonKey(name: "doneCount")
  int doneCount;
  @JsonKey(name: "totalCount")
  int totalCount;
  @JsonKey(name: "isEditedAssets")
  final List<bool>? isEditedAssets;
  @JsonKey(name: "gallery")
  List<GalleryModel>? gallery;
  @JsonKey(name: "isFirstRun")
  @JsonKey(name: "isFirstRun")
  bool isFirstRun;

  ThreadCreateTempModel({
    this.trainerId,
    this.title,
    required this.content,
    this.assetsPaths,
    required this.isLoading,
    required this.isUploading,
    required this.doneCount,
    required this.totalCount,
    this.isEditedAssets,
    this.gallery,
    required this.isFirstRun,
  });

  ThreadCreateTempModel copyWith({
    int? trainerId,
    String? title,
    String? content,
    List<String>? assetsPaths,
    bool? isLoading,
    bool? isUploading,
    bool? isFirstRun,
    int? doneCount,
    int? totalCount,
    List<bool>? isEditedAssets,
    List<GalleryModel>? gallery,
  }) =>
      ThreadCreateTempModel(
        trainerId: trainerId ?? this.trainerId,
        title: title ?? this.title,
        content: content ?? this.content,
        assetsPaths: assetsPaths ?? this.assetsPaths,
        isLoading: isLoading ?? this.isLoading,
        isUploading: isUploading ?? this.isUploading,
        doneCount: doneCount ?? this.doneCount,
        totalCount: totalCount ?? this.totalCount,
        isEditedAssets: isEditedAssets ?? this.isEditedAssets,
        gallery: gallery ?? this.gallery,
        isFirstRun: isFirstRun ?? this.isFirstRun,
      );

  factory ThreadCreateTempModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCreateTempModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCreateTempModelToJson(this);
}
