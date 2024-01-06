import 'package:json_annotation/json_annotation.dart';

part 'ticket_model.g.dart';

abstract class ActiveTicketResponseBase {}

class ActiveTicketResponseLoading extends ActiveTicketResponseBase {}

class ActiveTicketResponseError extends ActiveTicketResponseBase {
  final String error;
  final int statusCode;

  ActiveTicketResponseError({
    required this.error,
    required this.statusCode,
  });
}

@JsonSerializable()
class ActiveTicketResponse extends ActiveTicketResponseBase {
  @JsonKey(name: "data")
  final List<ActiveTicket> data;

  ActiveTicketResponse({
    required this.data,
  });

  ActiveTicketResponse copyWith({
    List<ActiveTicket>? data,
  }) =>
      ActiveTicketResponse(
        data: data ?? this.data,
      );

  factory ActiveTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$ActiveTicketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTicketResponseToJson(this);
}

@JsonSerializable()
class ActiveTicket {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "totalSession")
  final int totalSession;
  @JsonKey(name: "restSession")
  final int restSession;
  @JsonKey(name: "availSession")
  final int availSession;
  @JsonKey(name: "startedAt")
  final DateTime startedAt;
  @JsonKey(name: "expiredAt")
  final DateTime expiredAt;
  @JsonKey(name: "createdAt")
  final DateTime createdAt;
  @JsonKey(name: "receiptId")
  String? receiptId;
  @JsonKey(name: "users")
  final List<String> users;
  @JsonKey(name: "isHolding")
  final bool isHolding;

  ActiveTicket({
    required this.id,
    required this.type,
    required this.totalSession,
    required this.restSession,
    required this.availSession,
    required this.startedAt,
    required this.expiredAt,
    required this.createdAt,
    this.receiptId,
    required this.users,
    required this.isHolding,
  });

  ActiveTicket copyWith({
    int? id,
    String? type,
    int? totalSession,
    int? restSession,
    int? availSession,
    DateTime? startedAt,
    DateTime? expiredAt,
    DateTime? createdAt,
    String? receiptId,
    List<String>? users,
    bool? isHolding,
  }) =>
      ActiveTicket(
        id: id ?? this.id,
        type: type ?? this.type,
        totalSession: totalSession ?? this.totalSession,
        restSession: restSession ?? this.restSession,
        availSession: availSession ?? this.availSession,
        startedAt: startedAt ?? this.startedAt,
        expiredAt: expiredAt ?? this.expiredAt,
        createdAt: createdAt ?? this.createdAt,
        users: users ?? this.users,
        receiptId: receiptId ?? this.receiptId,
        isHolding: isHolding ?? this.isHolding,
      );

  factory ActiveTicket.fromJson(Map<String, dynamic> json) =>
      _$ActiveTicketFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTicketToJson(this);
}
