import 'package:json_annotation/json_annotation.dart';

part 'setInfo_model.g.dart';

@JsonSerializable()
class SetInfo {
  final int index;
  final int reps;
  final int weight;
  final int seconds;

  SetInfo({
    required this.index,
    required this.reps,
    required this.weight,
    required this.seconds,
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
}
