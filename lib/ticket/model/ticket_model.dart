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
  final List<TicketModel> data;

  ActiveTicketResponse({
    required this.data,
  });

  ActiveTicketResponse copyWith({
    List<TicketModel>? data,
  }) =>
      ActiveTicketResponse(
        data: data ?? this.data,
      );

  factory ActiveTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$ActiveTicketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTicketResponseToJson(this);
}

@JsonSerializable()
class TicketModel {
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
  @JsonKey(name: "month")
  int? month;

  TicketModel({
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
    this.month,
  });

  TicketModel copyWith({
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
    int? month,
  }) =>
      TicketModel(
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
        month: month ?? this.month,
      );

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketModelToJson(this);
}

abstract class TicketDetailListModelBase {}

class TicketDetailListModelLoading extends TicketDetailListModelBase {}

class TicketDetailListModelError extends TicketDetailListModelBase {
  final String message;

  TicketDetailListModelError({
    required this.message,
  });
}

@JsonSerializable()
class TicketDetailListModel extends TicketDetailListModelBase {
  @JsonKey(name: "data")
  final List<TicketDetailModel> data;

  TicketDetailListModel({
    required this.data,
  });

  TicketDetailListModel copyWith({
    List<TicketDetailModel>? data,
  }) =>
      TicketDetailListModel(
        data: data ?? this.data,
      );

  factory TicketDetailListModel.fromJson(Map<String, dynamic> json) =>
      _$TicketDetailListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketDetailListModelToJson(this);
}

@JsonSerializable()
class TicketDetailModel extends TicketModel {
  @JsonKey(name: "serviceSession")
  final int serviceSession;
  @JsonKey(name: "sessionPrice")
  final int sessionPrice;
  @JsonKey(name: "coachingPrice")
  final int coachingPrice;

  TicketDetailModel({
    required super.id,
    required super.type,
    required super.totalSession,
    required super.restSession,
    required super.availSession,
    required super.startedAt,
    required super.expiredAt,
    required super.createdAt,
    required super.users,
    required super.isHolding,
    super.month,
    super.receiptId,
    required this.serviceSession,
    required this.sessionPrice,
    required this.coachingPrice,
  });

  @override
  TicketDetailModel copyWith({
    int? id,
    String? type,
    int? totalSession,
    int? serviceSession,
    int? restSession,
    int? availSession,
    DateTime? startedAt,
    DateTime? expiredAt,
    DateTime? createdAt,
    int? sessionPrice,
    int? coachingPrice,
    List<String>? users,
    String? receiptId,
    bool? isHolding,
    int? month,
  }) =>
      TicketDetailModel(
        id: id ?? this.id,
        type: type ?? this.type,
        totalSession: totalSession ?? this.totalSession,
        serviceSession: serviceSession ?? this.serviceSession,
        restSession: restSession ?? this.restSession,
        availSession: availSession ?? this.availSession,
        startedAt: startedAt ?? this.startedAt,
        expiredAt: expiredAt ?? this.expiredAt,
        createdAt: createdAt ?? this.createdAt,
        sessionPrice: sessionPrice ?? this.sessionPrice,
        coachingPrice: coachingPrice ?? this.coachingPrice,
        users: users ?? this.users,
        receiptId: receiptId ?? this.receiptId,
        isHolding: isHolding ?? this.isHolding,
        month: month ?? this.month,
      );

  factory TicketDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TicketDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TicketDetailModelToJson(this);
}
