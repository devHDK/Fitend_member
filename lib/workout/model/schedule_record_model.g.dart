// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleRecordsModelAdapter extends TypeAdapter<ScheduleRecordsModel> {
  @override
  final int typeId = 8;

  @override
  ScheduleRecordsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleRecordsModel(
      workoutScheduleId: fields[1] as int?,
      heartRates: (fields[2] as List?)?.cast<int>(),
      workoutDuration: fields[3] as int?,
      calories: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleRecordsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.workoutScheduleId)
      ..writeByte(2)
      ..write(obj.heartRates)
      ..writeByte(3)
      ..write(obj.workoutDuration)
      ..writeByte(4)
      ..write(obj.calories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleRecordsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleRecordsModel _$ScheduleRecordsModelFromJson(
        Map<String, dynamic> json) =>
    ScheduleRecordsModel(
      workoutScheduleId: json['workoutScheduleId'] as int?,
      heartRates:
          (json['heartRates'] as List<dynamic>?)?.map((e) => e as int).toList(),
      workoutDuration: json['workoutDuration'] as int?,
      calories: json['calories'] as int?,
    );

Map<String, dynamic> _$ScheduleRecordsModelToJson(
        ScheduleRecordsModel instance) =>
    <String, dynamic>{
      'workoutScheduleId': instance.workoutScheduleId,
      'heartRates': instance.heartRates,
      'workoutDuration': instance.workoutDuration,
      'calories': instance.calories,
    };
