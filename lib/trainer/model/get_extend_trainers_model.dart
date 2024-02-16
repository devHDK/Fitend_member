import 'package:json_annotation/json_annotation.dart';

part 'get_extend_trainers_model.g.dart';

@JsonSerializable()
class GetExtendTrainersModel {
  String? search;
  final int start;
  final int perPage;

  GetExtendTrainersModel({
    this.search,
    required this.start,
    required this.perPage,
  });

  GetExtendTrainersModel copyWith({
    String? search,
    int? start,
    int? perPage,
  }) =>
      GetExtendTrainersModel(
        search: search ?? this.search,
        start: start ?? this.start,
        perPage: perPage ?? this.perPage,
      );

  factory GetExtendTrainersModel.fromJson(Map<String, dynamic> json) =>
      _$GetExtendTrainersModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetExtendTrainersModelToJson(this);
}
