import 'package:json_annotation/json_annotation.dart';

part 'post_password_reset.g.dart';

@JsonSerializable()
class PostPasswordReset {
  @JsonKey(name: "phoneToken")
  final String phoneToken;
  @JsonKey(name: "phone")
  final String phone;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "password")
  final String password;

  PostPasswordReset({
    required this.phoneToken,
    required this.phone,
    required this.email,
    required this.password,
  });

  PostPasswordReset copyWith({
    String? phoneToken,
    String? phone,
    String? email,
    String? password,
  }) =>
      PostPasswordReset(
        phoneToken: phoneToken ?? this.phoneToken,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  factory PostPasswordReset.fromJson(Map<String, dynamic> json) =>
      _$PostPasswordResetFromJson(json);

  Map<String, dynamic> toJson() => _$PostPasswordResetToJson(this);
}
