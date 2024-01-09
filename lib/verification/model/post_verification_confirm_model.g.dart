// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_verification_confirm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostVerificationConfirmModel _$PostVerificationConfirmModelFromJson(
        Map<String, dynamic> json) =>
    PostVerificationConfirmModel(
      codeToken: json['codeToken'] as String,
      code: json['code'] as int,
    );

Map<String, dynamic> _$PostVerificationConfirmModelToJson(
        PostVerificationConfirmModel instance) =>
    <String, dynamic>{
      'codeToken': instance.codeToken,
      'code': instance.code,
    };
