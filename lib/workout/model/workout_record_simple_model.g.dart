// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_record_simple_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutRecordSimpleAdapter extends TypeAdapter<WorkoutRecordSimple> {
  @override
  final int typeId = 1;

  @override
  WorkoutRecordSimple read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutRecordSimple(
      workoutPlanId: fields[1] as int,
      setInfo: (fields[2] as List).cast<SetInfo>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutRecordSimple obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.workoutPlanId)
      ..writeByte(2)
      ..write(obj.setInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutRecordSimpleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutRecordSimple _$WorkoutRecordSimpleFromJson(Map<String, dynamic> json) =>
    WorkoutRecordSimple(
      workoutPlanId: json['workoutPlanId'] as int,
      setInfo: (json['setInfo'] as List<dynamic>)
          .map((e) => SetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutRecordSimpleToJson(
        WorkoutRecordSimple instance) =>
    <String, dynamic>{
      'workoutPlanId': instance.workoutPlanId,
      'setInfo': instance.setInfo,
    };
