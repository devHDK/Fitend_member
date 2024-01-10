// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_user_register_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostUserRegisterModelAdapter extends TypeAdapter<PostUserRegisterModel> {
  @override
  final int typeId = 9;

  @override
  PostUserRegisterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostUserRegisterModel(
      trainerId: fields[1] as int?,
      nickname: fields[2] as String?,
      password: fields[3] as String?,
      email: fields[4] as String?,
      phone: fields[5] as String?,
      birth: fields[6] as DateTime?,
      gender: fields[7] as String?,
      height: fields[8] as int?,
      weight: fields[9] as int?,
      experience: fields[10] as int?,
      purpose: fields[11] as int?,
      achievement: (fields[12] as List?)?.cast<int>(),
      obstacle: (fields[13] as List?)?.cast<int>(),
      place: fields[14] as String?,
      preferDays: (fields[15] as List?)?.cast<int>(),
      step: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PostUserRegisterModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(1)
      ..write(obj.trainerId)
      ..writeByte(2)
      ..write(obj.nickname)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.birth)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.height)
      ..writeByte(9)
      ..write(obj.weight)
      ..writeByte(10)
      ..write(obj.experience)
      ..writeByte(11)
      ..write(obj.purpose)
      ..writeByte(12)
      ..write(obj.achievement)
      ..writeByte(13)
      ..write(obj.obstacle)
      ..writeByte(14)
      ..write(obj.place)
      ..writeByte(15)
      ..write(obj.preferDays)
      ..writeByte(16)
      ..write(obj.step);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostUserRegisterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostUserRegisterModel _$PostUserRegisterModelFromJson(
        Map<String, dynamic> json) =>
    PostUserRegisterModel(
      trainerId: json['trainerId'] as int?,
      nickname: json['nickname'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      birth: json['birth'] == null
          ? null
          : DateTime.parse(json['birth'] as String),
      gender: json['gender'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      experience: json['experience'] as int?,
      purpose: json['purpose'] as int?,
      achievement: (json['achievement'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      obstacle:
          (json['obstacle'] as List<dynamic>?)?.map((e) => e as int).toList(),
      place: json['place'] as String?,
      preferDays:
          (json['preferDays'] as List<dynamic>?)?.map((e) => e as int).toList(),
      step: json['step'] as String?,
    );

Map<String, dynamic> _$PostUserRegisterModelToJson(
        PostUserRegisterModel instance) =>
    <String, dynamic>{
      'trainerId': instance.trainerId,
      'nickname': instance.nickname,
      'password': instance.password,
      'email': instance.email,
      'phone': instance.phone,
      'birth': instance.birth?.toIso8601String(),
      'gender': instance.gender,
      'height': instance.height,
      'weight': instance.weight,
      'experience': instance.experience,
      'purpose': instance.purpose,
      'achievement': instance.achievement,
      'obstacle': instance.obstacle,
      'place': instance.place,
      'preferDays': instance.preferDays,
      'step': instance.step,
    };
