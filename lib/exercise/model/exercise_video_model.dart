import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_video_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 7)
class ExerciseVideo {
  @HiveField(1)
  final String url;
  @HiveField(2)
  final int index;
  @HiveField(3)
  final String thumbnail;

  ExerciseVideo({
    required this.url,
    required this.index,
    required this.thumbnail,
  });

  ExerciseVideo copyWith({
    String? url,
    int? index,
    String? thumbnail,
  }) =>
      ExerciseVideo(
        url: url ?? this.url,
        index: index ?? this.index,
        thumbnail: thumbnail ?? this.thumbnail,
      );

  factory ExerciseVideo.fromJson(Map<String, dynamic> json) =>
      _$ExerciseVideoFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseVideoToJson(this);
}
