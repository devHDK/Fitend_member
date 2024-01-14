import 'package:json_annotation/json_annotation.dart';

part 'get_trainer_schedule_model.g.dart';

@JsonSerializable()
class GetTrainerScheduleModel {
  final DateTime startDate;
  final DateTime endDate;

  GetTrainerScheduleModel({
    required this.startDate,
    required this.endDate,
  });

  GetTrainerScheduleModel copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      GetTrainerScheduleModel(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

  factory GetTrainerScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$GetTrainerScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetTrainerScheduleModelToJson(this);
}
