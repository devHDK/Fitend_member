// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutHistoryModel _$WorkoutHistoryModelFromJson(Map<String, dynamic> json) =>
    WorkoutHistoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as int,
      month: json['month'] as int,
      discountRate: json['discountRate'] as int,
    );

Map<String, dynamic> _$WorkoutHistoryModelToJson(
        WorkoutHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'month': instance.month,
      'discountRate': instance.discountRate,
    };
