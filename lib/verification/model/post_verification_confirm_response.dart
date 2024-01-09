import 'package:json_annotation/json_annotation.dart';

part 'post_verification_confirm_response.g.dart';

@JsonSerializable()
class PostVerificationConfirmResponse {
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "phoneToken")
  String? phoneToken;

  PostVerificationConfirmResponse({
    this.email,
    this.phoneToken,
  });

  PostVerificationConfirmResponse copyWith({
    String? email,
    String? phoneToken,
  }) =>
      PostVerificationConfirmResponse(
        email: email ?? this.email,
        phoneToken: phoneToken ?? this.phoneToken,
      );

  factory PostVerificationConfirmResponse.fromJson(Map<String, dynamic> json) =>
      _$PostVerificationConfirmResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PostVerificationConfirmResponseToJson(this);
}
