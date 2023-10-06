import 'package:json_annotation/json_annotation.dart';

part 'gallery_model.g.dart';

@JsonSerializable()
class GalleryModel {
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "url")
  final String url;
  @JsonKey(name: "thumbnail")
  String? thumbnail;

  GalleryModel({
    required this.type,
    required this.url,
    required this.thumbnail,
  });

  GalleryModel copyWith({
    String? type,
    String? url,
    String? thumbnail,
  }) =>
      GalleryModel(
        type: type ?? this.type,
        url: url ?? this.url,
        thumbnail: thumbnail ?? this.thumbnail,
      );

  factory GalleryModel.fromJson(Map<String, dynamic> json) =>
      _$GalleryModelFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryModelToJson(this);
}
