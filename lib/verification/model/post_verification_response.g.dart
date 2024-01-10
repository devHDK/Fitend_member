// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_verification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostVerificationResponse _$PostVerificationResponseFromJson(
        Map<String, dynamic> json) =>
    PostVerificationResponse(
      codeToken: json['codeToken'] as String,
      expireAt: DateTime.parse(json['expireAt'] as String),
    );

Map<String, dynamic> _$PostVerificationResponseToJson(
        PostVerificationResponse instance) =>
    <String, dynamic>{
      'codeToken': instance.codeToken,
      'expireAt': instance.expireAt.toIso8601String(),
    };
