// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_confirm_req_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentConfirmReqModel _$PaymentConfirmReqModelFromJson(
        Map<String, dynamic> json) =>
    PaymentConfirmReqModel(
      receiptId: json['receiptId'] as String,
      orderId: json['orderId'] as String,
      price: json['price'] as int,
      orderName: json['orderName'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      trainerId: json['trainerId'] as int,
      userId: json['userId'] as int,
      month: json['month'] as int,
    );

Map<String, dynamic> _$PaymentConfirmReqModelToJson(
        PaymentConfirmReqModel instance) =>
    <String, dynamic>{
      'receiptId': instance.receiptId,
      'orderId': instance.orderId,
      'price': instance.price,
      'orderName': instance.orderName,
      'startedAt': instance.startedAt.toIso8601String(),
      'expiredAt': instance.expiredAt.toIso8601String(),
      'trainerId': instance.trainerId,
      'userId': instance.userId,
      'month': instance.month,
    };
