// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_params_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutEmojiParamsModel _$PutEmojiParamsModelFromJson(Map<String, dynamic> json) =>
    PutEmojiParamsModel(
      emoji: json['emoji'] as String?,
      threadId: json['threadId'] as int?,
      commentId: json['commentId'] as int?,
    );

Map<String, dynamic> _$PutEmojiParamsModelToJson(
        PutEmojiParamsModel instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'threadId': instance.threadId,
      'commentId': instance.commentId,
    };
