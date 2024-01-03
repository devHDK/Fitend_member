import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class WorkoutHistoryModel {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "price")
  final int price;
  @JsonKey(name: "month")
  final int month;
  @JsonKey(name: "discountRate")
  final int discountRate;

  WorkoutHistoryModel({
    required this.id,
    required this.name,
    required this.price,
    required this.month,
    required this.discountRate,
  });

  WorkoutHistoryModel copyWith({
    int? id,
    String? name,
    int? price,
    int? month,
    int? discountRate,
  }) =>
      WorkoutHistoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        month: month ?? this.month,
        discountRate: discountRate ?? this.discountRate,
      );

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutHistoryModelToJson(this);
}
