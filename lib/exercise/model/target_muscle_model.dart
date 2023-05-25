import 'package:json_annotation/json_annotation.dart';

part 'target_muscle_model.g.dart';

@JsonSerializable()
class TargetMuscle {
  final String name;
  final String muscleType;
  final String type;
  final String image;

  TargetMuscle({
    required this.name,
    required this.muscleType,
    required this.type,
    required this.image,
  });

  TargetMuscle copyWith({
    String? name,
    String? muscleType,
    String? type,
    String? image,
  }) =>
      TargetMuscle(
        name: name ?? this.name,
        muscleType: muscleType ?? this.muscleType,
        type: type ?? this.type,
        image: image ?? this.image,
      );

  factory TargetMuscle.fromJson(Map<String, dynamic> json) =>
      _$TargetMuscleFromJson(json);
}
