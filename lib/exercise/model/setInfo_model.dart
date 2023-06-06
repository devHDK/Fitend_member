import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'setInfo_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class SetInfo {
  @HiveField(1)
  final int index;
  @HiveField(2)
  int? reps;
  @HiveField(3)
  int? weight;
  @HiveField(4)
  int? seconds;

  SetInfo({
    required this.index,
    this.reps,
    this.weight,
    this.seconds,
  });

  SetInfo copyWith({
    int? index,
    int? reps,
    int? weight,
    int? seconds,
  }) =>
      SetInfo(
        index: index ?? this.index,
        reps: reps ?? this.reps,
        weight: weight ?? this.weight,
        seconds: seconds ?? this.seconds,
      );

  factory SetInfo.fromJson(Map<String, dynamic> json) =>
      _$SetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SetInfoToJson(this);
}
