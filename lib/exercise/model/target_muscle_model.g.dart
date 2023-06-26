// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_muscle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TargetMuscleAdapter extends TypeAdapter<TargetMuscle> {
  @override
  final int typeId = 6;

  @override
  TargetMuscle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TargetMuscle(
      id: fields[1] as int,
      name: fields[2] as String,
      muscleType: fields[3] as String,
      type: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TargetMuscle obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.muscleType)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetMuscleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetMuscle _$TargetMuscleFromJson(Map<String, dynamic> json) => TargetMuscle(
      id: json['id'] as int,
      name: json['name'] as String,
      muscleType: json['muscleType'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TargetMuscleToJson(TargetMuscle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'muscleType': instance.muscleType,
      'type': instance.type,
    };
