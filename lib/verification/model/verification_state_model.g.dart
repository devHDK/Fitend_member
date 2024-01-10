// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationStateModel _$VerificationStateModelFromJson(
        Map<String, dynamic> json) =>
    VerificationStateModel(
      isMessageSended: json['isMessageSended'] as bool,
      isCodeSended: json['isCodeSended'] as bool,
      phoneNumber: json['phoneNumber'] as String?,
      codeToken: json['codeToken'] as String?,
      expireAt: json['expireAt'] == null
          ? null
          : DateTime.parse(json['expireAt'] as String),
      code: json['code'] as int?,
    );

Map<String, dynamic> _$VerificationStateModelToJson(
        VerificationStateModel instance) =>
    <String, dynamic>{
      'isMessageSended': instance.isMessageSended,
      'isCodeSended': instance.isCodeSended,
      'phoneNumber': instance.phoneNumber,
      'codeToken': instance.codeToken,
      'expireAt': instance.expireAt?.toIso8601String(),
      'code': instance.code,
    };
