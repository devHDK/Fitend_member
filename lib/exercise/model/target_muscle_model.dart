import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'target_muscle_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 6)
class TargetMuscle {
  @HiveField(1)
  final int id;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String muscleType;
  @HiveField(4)
  final String type;

  TargetMuscle({
    required this.id,
    required this.name,
    required this.muscleType,
    required this.type,
  });

  TargetMuscle copyWith({
    int? id,
    String? name,
    String? muscleType,
    String? type,
  }) =>
      TargetMuscle(
        id: id ?? this.id,
        name: name ?? this.name,
        muscleType: muscleType ?? this.muscleType,
        type: type ?? this.type,
      );

  factory TargetMuscle.fromJson(Map<String, dynamic> json) =>
      _$TargetMuscleFromJson(json);

  Map<String, dynamic> toJson() => _$TargetMuscleToJson(this);
}
