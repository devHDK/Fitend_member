import 'package:json_annotation/json_annotation.dart';

part 'bootpay_confirm_response.g.dart';

@JsonSerializable()
class BootPayConfirmResponse {
  @JsonKey(name: "event")
  final String event;
  @JsonKey(name: "receipt_id")
  final String receiptId;
  @JsonKey(name: "order_id")
  final String orderId;
  @JsonKey(name: "on_inapp_sdk")
  final bool onInappSdk;
  @JsonKey(name: "gateway_url")
  final String gatewayUrl;
  @JsonKey(name: "bootpay_event")
  final bool bootpayEvent;

  BootPayConfirmResponse({
    required this.event,
    required this.receiptId,
    required this.orderId,
    required this.onInappSdk,
    required this.gatewayUrl,
    required this.bootpayEvent,
  });

  BootPayConfirmResponse copyWith({
    String? event,
    String? receiptId,
    String? orderId,
    bool? onInappSdk,
    String? gatewayUrl,
    bool? bootpayEvent,
  }) =>
      BootPayConfirmResponse(
        event: event ?? this.event,
        receiptId: receiptId ?? this.receiptId,
        orderId: orderId ?? this.orderId,
        onInappSdk: onInappSdk ?? this.onInappSdk,
        gatewayUrl: gatewayUrl ?? this.gatewayUrl,
        bootpayEvent: bootpayEvent ?? this.bootpayEvent,
      );

  factory BootPayConfirmResponse.fromJson(Map<String, dynamic> json) =>
      _$BootPayConfirmResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BootPayConfirmResponseToJson(this);
}
