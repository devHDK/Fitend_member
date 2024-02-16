import 'package:json_annotation/json_annotation.dart';
part 'bool_model.g.dart';

@JsonSerializable()
class BoolModel {
  @JsonKey(name: "data")
  final bool data;

  BoolModel({
    required this.data,
  });

  BoolModel copyWith({
    bool? data,
  }) =>
      BoolModel(
        data: data ?? this.data,
      );

  factory BoolModel.fromJson(Map<String, dynamic> json) =>
      _$BoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoolModelToJson(this);
}
