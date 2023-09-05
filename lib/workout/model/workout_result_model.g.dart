// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutRecordAdapter extends TypeAdapter<WorkoutRecord> {
  @override
  final int typeId = 3;

  @override
  WorkoutRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutRecord(
      exerciseName: fields[1] as String,
      targetMuscles: (fields[2] as List).cast<String>(),
      trackingFieldId: fields[3] as int,
      workoutPlanId: fields[4] as int,
      setInfo: (fields[5] as List).cast<SetInfo>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.targetMuscles)
      ..writeByte(3)
      ..write(obj.trackingFieldId)
      ..writeByte(4)
      ..write(obj.workoutPlanId)
      ..writeByte(5)
      ..write(obj.setInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutResultModel _$WorkoutResultModelFromJson(Map<String, dynamic> json) =>
    WorkoutResultModel(
      startDate: json['startDate'] as String,
      strengthIndex: json['strengthIndex'] as int,
      issueIndexes: (json['issueIndexes'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      contents: json['contents'] as String?,
      workoutRecords: (json['workoutRecords'] as List<dynamic>)
          .map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutResultModelToJson(WorkoutResultModel instance) =>
    <String, dynamic>{
      'startDate': instance.startDate,
      'strengthIndex': instance.strengthIndex,
      'issueIndexes': instance.issueIndexes,
      'contents': instance.contents,
      'workoutRecords': instance.workoutRecords,
    };

WorkoutRecord _$WorkoutRecordFromJson(Map<String, dynamic> json) =>
    WorkoutRecord(
      exerciseName: json['exerciseName'] as String,
      targetMuscles: (json['targetMuscles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      trackingFieldId: json['trackingFieldId'] as int,
      workoutPlanId: json['workoutPlanId'] as int,
      setInfo: (json['setInfo'] as List<dynamic>)
          .map((e) => SetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutRecordToJson(WorkoutRecord instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'targetMuscles': instance.targetMuscles,
      'trackingFieldId': instance.trackingFieldId,
      'workoutPlanId': instance.workoutPlanId,
      'setInfo': instance.setInfo,
    };
