import 'package:json_annotation/json_annotation.dart';

part 'post_verification_confirm_model.g.dart';

@JsonSerializable()
class PostVerificationConfirmModel {
  @JsonKey(name: "codeToken")
  final String codeToken;
  @JsonKey(name: "code")
  final int code;

  PostVerificationConfirmModel({
    required this.codeToken,
    required this.code,
  });

  PostVerificationConfirmModel copyWith({
    String? codeToken,
    int? code,
  }) =>
      PostVerificationConfirmModel(
        codeToken: codeToken ?? this.codeToken,
        code: code ?? this.code,
      );

  factory PostVerificationConfirmModel.fromJson(Map<String, dynamic> json) =>
      _$PostVerificationConfirmModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostVerificationConfirmModelToJson(this);
}
