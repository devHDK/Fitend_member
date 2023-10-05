import 'package:json_annotation/json_annotation.dart';

part 'file_upload_request_model.g.dart';

@JsonSerializable()
class FileRequestModel {
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "mimeType")
  final String mimeType;

  FileRequestModel({
    required this.type,
    required this.mimeType,
  });

  FileRequestModel copyWith({
    String? type,
    String? mimeType,
  }) =>
      FileRequestModel(
        type: type ?? this.type,
        mimeType: mimeType ?? this.mimeType,
      );

  factory FileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$FileRequestModelToJson(this);
}
