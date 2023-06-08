import 'package:json_annotation/json_annotation.dart';

part 'target_muscle_model.g.dart';

@JsonSerializable()
class TargetMuscle {
  final int id;
  final String name;
  final String muscleType;
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
}
