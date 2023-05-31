// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setInfo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetInfoAdapter extends TypeAdapter<SetInfo> {
  @override
  final int typeId = 2;

  @override
  SetInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetInfo(
      index: fields[1] as int,
      reps: fields[2] as int?,
      weight: fields[3] as int?,
      seconds: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SetInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.index)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.seconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetInfo _$SetInfoFromJson(Map<String, dynamic> json) => SetInfo(
      index: json['index'] as int,
      reps: json['reps'] as int?,
      weight: json['weight'] as int?,
      seconds: json['seconds'] as int?,
    );

Map<String, dynamic> _$SetInfoToJson(SetInfo instance) => <String, dynamic>{
      'index': instance.index,
      'reps': instance.reps,
      'weight': instance.weight,
      'seconds': instance.seconds,
    };
