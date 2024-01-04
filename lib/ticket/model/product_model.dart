import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

abstract class ProductsModelBase {}

class ProductsModelError extends ProductsModelBase {
  final String message;

  ProductsModelError({
    required this.message,
  });
}

class ProductsModelLoading extends ProductsModelBase {}

@JsonSerializable()
class ProductsModel extends ProductsModelBase {
  @JsonKey(name: "data")
  final List<Product> data;
  int? selectedIndex;

  ProductsModel({required this.data, this.selectedIndex});

  ProductsModel copyWith({
    List<Product>? data,
    int? selectedIndex,
  }) =>
      ProductsModel(
        data: data ?? this.data,
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );

  factory ProductsModel.fromJson(Map<String, dynamic> json) =>
      _$ProductsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsModelToJson(this);
}

@JsonSerializable()
class Product {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "price")
  final int price;
  @JsonKey(name: "originPrice")
  final int originPrice;
  @JsonKey(name: "month")
  final int month;
  @JsonKey(name: "discountRate")
  final int discountRate;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originPrice,
    required this.month,
    required this.discountRate,
  });

  Product copyWith({
    int? id,
    String? name,
    int? price,
    int? originPrice,
    int? month,
    int? discountRate,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        originPrice: originPrice ?? this.originPrice,
        month: month ?? this.month,
        discountRate: discountRate ?? this.discountRate,
      );

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
