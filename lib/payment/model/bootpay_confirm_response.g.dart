// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootpay_confirm_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BootPayConfirmResponse _$BootPayConfirmResponseFromJson(
        Map<String, dynamic> json) =>
    BootPayConfirmResponse(
      event: json['event'] as String,
      receiptId: json['receipt_id'] as String,
      orderId: json['order_id'] as String,
      onInappSdk: json['on_inapp_sdk'] as bool,
      gatewayUrl: json['gateway_url'] as String,
      bootpayEvent: json['bootpay_event'] as bool,
    );

Map<String, dynamic> _$BootPayConfirmResponseToJson(
        BootPayConfirmResponse instance) =>
    <String, dynamic>{
      'event': instance.event,
      'receipt_id': instance.receiptId,
      'order_id': instance.orderId,
      'on_inapp_sdk': instance.onInappSdk,
      'gateway_url': instance.gatewayUrl,
      'bootpay_event': instance.bootpayEvent,
    };
