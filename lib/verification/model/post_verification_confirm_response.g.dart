// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_verification_confirm_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostVerificationConfirmResponse _$PostVerificationConfirmResponseFromJson(
        Map<String, dynamic> json) =>
    PostVerificationConfirmResponse(
      email: json['email'] as String?,
      phoneToken: json['phoneToken'] as String?,
    );

Map<String, dynamic> _$PostVerificationConfirmResponseToJson(
        PostVerificationConfirmResponse instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phoneToken': instance.phoneToken,
    };
