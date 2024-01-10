import 'package:json_annotation/json_annotation.dart';

part 'post_verification_response.g.dart';

@JsonSerializable()
class PostVerificationResponse {
  @JsonKey(name: "codeToken")
  final String codeToken;
  @JsonKey(name: "expireAt")
  final DateTime expireAt;

  PostVerificationResponse({
    required this.codeToken,
    required this.expireAt,
  });

  PostVerificationResponse copyWith({
    String? codeToken,
    DateTime? expireAt,
  }) =>
      PostVerificationResponse(
        codeToken: codeToken ?? this.codeToken,
        expireAt: expireAt ?? this.expireAt,
      );

  factory PostVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$PostVerificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostVerificationResponseToJson(this);
}
