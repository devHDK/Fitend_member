import 'package:json_annotation/json_annotation.dart';

part 'create_resp_model.g.dart';

@JsonSerializable()
class CreateRespModel {
  @JsonKey(name: "id")
  final int id;

  CreateRespModel({
    required this.id,
  });

  CreateRespModel copyWith({
    int? id,
  }) =>
      CreateRespModel(
        id: id ?? this.id,
      );

  factory CreateRespModel.fromJson(Map<String, dynamic> json) =>
      _$CreateRespModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRespModelToJson(this);
}
