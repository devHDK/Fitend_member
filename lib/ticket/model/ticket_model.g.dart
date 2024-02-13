// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveTicketResponse _$ActiveTicketResponseFromJson(
        Map<String, dynamic> json) =>
    ActiveTicketResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActiveTicketResponseToJson(
        ActiveTicketResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

TicketModel _$TicketModelFromJson(Map<String, dynamic> json) => TicketModel(
      id: json['id'] as int,
      type: json['type'] as String,
      totalSession: json['totalSession'] as int,
      restSession: json['restSession'] as int,
      availSession: json['availSession'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      receiptId: json['receiptId'] as String?,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      isHolding: json['isHolding'] as bool,
      month: json['month'] as int?,
    );

Map<String, dynamic> _$TicketModelToJson(TicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'totalSession': instance.totalSession,
      'restSession': instance.restSession,
      'availSession': instance.availSession,
      'startedAt': instance.startedAt.toIso8601String(),
      'expiredAt': instance.expiredAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'receiptId': instance.receiptId,
      'users': instance.users,
      'isHolding': instance.isHolding,
      'month': instance.month,
    };

TicketDetailListModel _$TicketDetailListModelFromJson(
        Map<String, dynamic> json) =>
    TicketDetailListModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => TicketDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TicketDetailListModelToJson(
        TicketDetailListModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

TicketDetailModel _$TicketDetailModelFromJson(Map<String, dynamic> json) =>
    TicketDetailModel(
      id: json['id'] as int,
      type: json['type'] as String,
      totalSession: json['totalSession'] as int,
      restSession: json['restSession'] as int,
      availSession: json['availSession'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      isHolding: json['isHolding'] as bool,
      month: json['month'] as int?,
      receiptId: json['receiptId'] as String?,
      serviceSession: json['serviceSession'] as int,
      sessionPrice: json['sessionPrice'] as int,
      coachingPrice: json['coachingPrice'] as int,
    );

Map<String, dynamic> _$TicketDetailModelToJson(TicketDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'totalSession': instance.totalSession,
      'restSession': instance.restSession,
      'availSession': instance.availSession,
      'startedAt': instance.startedAt.toIso8601String(),
      'expiredAt': instance.expiredAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'receiptId': instance.receiptId,
      'users': instance.users,
      'isHolding': instance.isHolding,
      'month': instance.month,
      'serviceSession': instance.serviceSession,
      'sessionPrice': instance.sessionPrice,
      'coachingPrice': instance.coachingPrice,
    };
