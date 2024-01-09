// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostVerificationModel _$PostVerificationModelFromJson(
        Map<String, dynamic> json) =>
    PostVerificationModel(
      type: json['type'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$PostVerificationModelToJson(
        PostVerificationModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'phone': instance.phone,
    };
