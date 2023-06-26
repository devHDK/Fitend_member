import 'dart:convert';

class PostConfirmPassword {
  final String password;

  PostConfirmPassword({
    required this.password,
  });

  PostConfirmPassword copyWith({
    String? password,
  }) =>
      PostConfirmPassword(
        password: password ?? this.password,
      );

  factory PostConfirmPassword.fromRawJson(String str) =>
      PostConfirmPassword.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostConfirmPassword.fromJson(Map<String, dynamic> json) =>
      PostConfirmPassword(
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "password": password,
      };
}
