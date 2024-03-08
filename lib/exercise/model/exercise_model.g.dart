// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 5;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      workoutPlanId: fields[1] as int,
      name: fields[2] as String,
      description: fields[3] as String,
      trackingFieldId: fields[4] as int,
      trainerNickname: fields[5] as String,
      trainerProfileImage: fields[6] as String,
      targetMuscles: (fields[7] as List).cast<TargetMuscle>(),
      videos: (fields[8] as List).cast<ExerciseVideo>(),
      setInfo: (fields[9] as List).cast<SetInfo>(),
      circuitGroupNum: fields[10] as int?,
      circuitSeq: fields[11] as int?,
      setType: fields[12] as String?,
      isVideoRecord: fields[13] as bool?,
      devisionId: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(14)
      ..writeByte(1)
      ..write(obj.workoutPlanId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.trackingFieldId)
      ..writeByte(5)
      ..write(obj.trainerNickname)
      ..writeByte(6)
      ..write(obj.trainerProfileImage)
      ..writeByte(7)
      ..write(obj.targetMuscles)
      ..writeByte(8)
      ..write(obj.videos)
      ..writeByte(9)
      ..write(obj.setInfo)
      ..writeByte(10)
      ..write(obj.circuitGroupNum)
      ..writeByte(11)
      ..write(obj.circuitSeq)
      ..writeByte(12)
      ..write(obj.setType)
      ..writeByte(13)
      ..write(obj.isVideoRecord)
      ..writeByte(14)
      ..write(obj.devisionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      workoutPlanId: json['workoutPlanId'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      trackingFieldId: json['trackingFieldId'] as int,
      trainerNickname: json['trainerNickname'] as String,
      trainerProfileImage: json['trainerProfileImage'] as String,
      targetMuscles: (json['targetMuscles'] as List<dynamic>)
          .map((e) => TargetMuscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => ExerciseVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      setInfo: (json['setInfo'] as List<dynamic>)
          .map((e) => SetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      circuitGroupNum: json['circuitGroupNum'] as int?,
      circuitSeq: json['circuitSeq'] as int?,
      setType: json['setType'] as String?,
      isVideoRecord: json['isVideoRecord'] as bool?,
      devisionId: json['devisionId'] as int?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'workoutPlanId': instance.workoutPlanId,
      'name': instance.name,
      'description': instance.description,
      'trackingFieldId': instance.trackingFieldId,
      'trainerNickname': instance.trainerNickname,
      'trainerProfileImage': instance.trainerProfileImage,
      'targetMuscles': instance.targetMuscles,
      'videos': instance.videos,
      'setInfo': instance.setInfo,
      'circuitGroupNum': instance.circuitGroupNum,
      'circuitSeq': instance.circuitSeq,
      'setType': instance.setType,
      'isVideoRecord': instance.isVideoRecord,
      'devisionId': instance.devisionId,
    };
