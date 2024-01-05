import 'package:json_annotation/json_annotation.dart';

part 'payment_confirm_req_model.g.dart';

@JsonSerializable()
class PaymentConfirmReqModel {
  @JsonKey(name: "receiptId")
  final String receiptId;
  @JsonKey(name: "orderId")
  final String orderId;
  @JsonKey(name: "price")
  final int price;
  @JsonKey(name: "orderName")
  final String orderName;
  @JsonKey(name: "startedAt")
  final DateTime startedAt;
  @JsonKey(name: "expiredAt")
  final DateTime expiredAt;
  @JsonKey(name: "trainerId")
  final int trainerId;
  @JsonKey(name: "userId")
  final int userId;
  @JsonKey(name: "month")
  final int month;

  PaymentConfirmReqModel({
    required this.receiptId,
    required this.orderId,
    required this.price,
    required this.orderName,
    required this.startedAt,
    required this.expiredAt,
    required this.trainerId,
    required this.userId,
    required this.month,
  });

  PaymentConfirmReqModel copyWith({
    String? receiptId,
    String? orderId,
    int? price,
    String? orderName,
    DateTime? startedAt,
    DateTime? expiredAt,
    int? trainerId,
    int? userId,
    int? month,
  }) =>
      PaymentConfirmReqModel(
        receiptId: receiptId ?? this.receiptId,
        orderId: orderId ?? this.orderId,
        price: price ?? this.price,
        orderName: orderName ?? this.orderName,
        startedAt: startedAt ?? this.startedAt,
        expiredAt: expiredAt ?? this.expiredAt,
        trainerId: trainerId ?? this.trainerId,
        userId: userId ?? this.userId,
        month: month ?? this.month,
      );

  factory PaymentConfirmReqModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentConfirmReqModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentConfirmReqModelToJson(this);
}
