// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmojiModel _$EmojiModelFromJson(Map<String, dynamic> json) => EmojiModel(
      id: json['id'] as int,
      emoji: json['emoji'] as String,
      userId: json['userId'] as int?,
      trainerId: json['trainerId'] as int?,
    );

Map<String, dynamic> _$EmojiModelToJson(EmojiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'userId': instance.userId,
      'trainerId': instance.trainerId,
    };

EmojiModelFromPushData _$EmojiModelFromPushDataFromJson(
        Map<String, dynamic> json) =>
    EmojiModelFromPushData(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      userId: json['userId'] as String?,
      trainerId: json['trainerId'] as String?,
      threadId: json['threadId'] as String?,
      commentId: json['commentId'] as String?,
    );

Map<String, dynamic> _$EmojiModelFromPushDataToJson(
        EmojiModelFromPushData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'userId': instance.userId,
      'trainerId': instance.trainerId,
      'threadId': instance.threadId,
      'commentId': instance.commentId,
    };
