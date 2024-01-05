// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveTicketResponse _$ActiveTicketResponseFromJson(
        Map<String, dynamic> json) =>
    ActiveTicketResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ActiveTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActiveTicketResponseToJson(
        ActiveTicketResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

ActiveTicket _$ActiveTicketFromJson(Map<String, dynamic> json) => ActiveTicket(
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
    );

Map<String, dynamic> _$ActiveTicketToJson(ActiveTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'totalSession': instance.totalSession,
      'restSession': instance.restSession,
      'availSession': instance.availSession,
      'startedAt': instance.startedAt.toIso8601String(),
      'expiredAt': instance.expiredAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'users': instance.users,
      'isHolding': instance.isHolding,
    };
