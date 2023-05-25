import 'package:json_annotation/json_annotation.dart';

part 'exercise_video_model.g.dart';

@JsonSerializable()
class ExerciseVideo {
  final String url;
  final int index;
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
}
