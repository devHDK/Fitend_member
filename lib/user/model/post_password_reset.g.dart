// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_password_reset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPasswordReset _$PostPasswordResetFromJson(Map<String, dynamic> json) =>
    PostPasswordReset(
      phoneToken: json['phoneToken'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$PostPasswordResetToJson(PostPasswordReset instance) =>
    <String, dynamic>{
      'phoneToken': instance.phoneToken,
      'phone': instance.phone,
      'email': instance.email,
      'password': instance.password,
    };
