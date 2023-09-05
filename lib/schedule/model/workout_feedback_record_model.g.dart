// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_feedback_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutFeedbackRecordModelAdapter
    extends TypeAdapter<WorkoutFeedbackRecordModel> {
  @override
  final int typeId = 4;

  @override
  WorkoutFeedbackRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutFeedbackRecordModel(
      startDate: fields[1] as DateTime,
      strengthIndex: fields[2] as int?,
      issueIndexes: (fields[3] as List?)?.cast<int>(),
      contents: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutFeedbackRecordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.strengthIndex)
      ..writeByte(3)
      ..write(obj.issueIndexes)
      ..writeByte(4)
      ..write(obj.contents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutFeedbackRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutFeedbackRecordModel _$WorkoutFeedbackRecordModelFromJson(
        Map<String, dynamic> json) =>
    WorkoutFeedbackRecordModel(
      startDate: DateTime.parse(json['startDate'] as String),
      strengthIndex: json['strengthIndex'] as int?,
      issueIndexes: (json['issueIndexes'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      contents: json['contents'] as String?,
    );

Map<String, dynamic> _$WorkoutFeedbackRecordModelToJson(
        WorkoutFeedbackRecordModel instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'strengthIndex': instance.strengthIndex,
      'issueIndexes': instance.issueIndexes,
      'contents': instance.contents,
    };
