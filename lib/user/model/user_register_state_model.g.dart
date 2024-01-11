// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_register_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRegisterStateModelAdapter
    extends TypeAdapter<UserRegisterStateModel> {
  @override
  final int typeId = 9;

  @override
  UserRegisterStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserRegisterStateModel(
      trainerId: fields[1] as int?,
      nickname: fields[3] as String?,
      password: fields[5] as String?,
      email: fields[7] as String?,
      phone: fields[9] as String?,
      birth: fields[11] as DateTime?,
      gender: fields[13] as String?,
      height: fields[15] as double?,
      weight: fields[17] as double?,
      experience: fields[19] as int?,
      purpose: fields[21] as int?,
      achievement: (fields[23] as List?)?.cast<int>(),
      obstacle: (fields[25] as List?)?.cast<int>(),
      place: fields[27] as String?,
      preferDays: (fields[29] as List?)?.cast<int>(),
      step: fields[31] as int?,
      progressStep: fields[33] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserRegisterStateModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(1)
      ..write(obj.trainerId)
      ..writeByte(3)
      ..write(obj.nickname)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(11)
      ..write(obj.birth)
      ..writeByte(13)
      ..write(obj.gender)
      ..writeByte(15)
      ..write(obj.height)
      ..writeByte(17)
      ..write(obj.weight)
      ..writeByte(19)
      ..write(obj.experience)
      ..writeByte(21)
      ..write(obj.purpose)
      ..writeByte(23)
      ..write(obj.achievement)
      ..writeByte(25)
      ..write(obj.obstacle)
      ..writeByte(27)
      ..write(obj.place)
      ..writeByte(29)
      ..write(obj.preferDays)
      ..writeByte(31)
      ..write(obj.step)
      ..writeByte(33)
      ..write(obj.progressStep);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRegisterStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRegisterStateModel _$UserRegisterStateModelFromJson(
        Map<String, dynamic> json) =>
    UserRegisterStateModel(
      trainerId: json['trainerId'] as int?,
      nickname: json['nickname'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      birth: json['birth'] == null
          ? null
          : DateTime.parse(json['birth'] as String),
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
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
      step: json['step'] as int?,
      progressStep: json['progressStep'] as int?,
    );

Map<String, dynamic> _$UserRegisterStateModelToJson(
        UserRegisterStateModel instance) =>
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
      'progressStep': instance.progressStep,
    };
