import 'package:json_annotation/json_annotation.dart';

part 'post_verification_model.g.dart';

@JsonSerializable()
class PostVerificationModel {
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "phone")
  final String phone;

  PostVerificationModel({
    required this.type,
    required this.phone,
  });

  PostVerificationModel copyWith({
    String? type,
    String? phone,
  }) =>
      PostVerificationModel(
        type: type ?? this.type,
        phone: phone ?? this.phone,
      );

  factory PostVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$PostVerificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostVerificationModelToJson(this);
}

class VerificationType {
  static String register = 'register';
  static String reset = 'reset';
  static String id = 'id';
}
