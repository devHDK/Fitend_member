import 'dart:convert';

class PostChangePassword {
  final String password;
  final String newPassword;

  PostChangePassword({
    required this.password,
    required this.newPassword,
  });

  PostChangePassword copyWith({
    String? password,
    String? newPassword,
  }) =>
      PostChangePassword(
        password: password ?? this.password,
        newPassword: newPassword ?? this.newPassword,
      );

  factory PostChangePassword.fromRawJson(String str) =>
      PostChangePassword.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostChangePassword.fromJson(Map<String, dynamic> json) =>
      PostChangePassword(
        password: json["password"],
        newPassword: json["newPassword"],
      );

  Map<String, dynamic> toJson() => {
        "password": password,
        "newPassword": newPassword,
      };
}
