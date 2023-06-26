// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseVideoAdapter extends TypeAdapter<ExerciseVideo> {
  @override
  final int typeId = 7;

  @override
  ExerciseVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseVideo(
      url: fields[1] as String,
      index: fields[2] as int,
      thumbnail: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseVideo obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.index)
      ..writeByte(3)
      ..write(obj.thumbnail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseVideo _$ExerciseVideoFromJson(Map<String, dynamic> json) =>
    ExerciseVideo(
      url: json['url'] as String,
      index: json['index'] as int,
      thumbnail: json['thumbnail'] as String,
    );

Map<String, dynamic> _$ExerciseVideoToJson(ExerciseVideo instance) =>
    <String, dynamic>{
      'url': instance.url,
      'index': instance.index,
      'thumbnail': instance.thumbnail,
    };
