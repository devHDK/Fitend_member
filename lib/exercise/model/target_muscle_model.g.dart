// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_muscle_model.dart';

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
