import 'package:json_annotation/json_annotation.dart';

part 'post_email_exist_model.g.dart';

@JsonSerializable()
class PostEmailExistModel {
  @JsonKey(name: "email")
  final String email;

  PostEmailExistModel({
    required this.email,
  });

  PostEmailExistModel copyWith({
    String? email,
  }) =>
      PostEmailExistModel(
        email: email ?? this.email,
      );

  factory PostEmailExistModel.fromJson(Map<String, dynamic> json) =>
      _$PostEmailExistModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostEmailExistModelToJson(this);
}
