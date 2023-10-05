import 'package:json_annotation/json_annotation.dart';

part 'file_upload_response_model.g.dart';

@JsonSerializable()
class FileResponseModel {
  @JsonKey(name: "path")
  final String path;
  @JsonKey(name: "url")
  final String url;

  FileResponseModel({
    required this.path,
    required this.url,
  });

  FileResponseModel copyWith({
    String? path,
    String? url,
  }) =>
      FileResponseModel(
        path: path ?? this.path,
        url: url ?? this.url,
      );

  factory FileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FileResponseModelToJson(this);
}
