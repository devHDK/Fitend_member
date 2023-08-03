// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationScheduleModel _$ReservationScheduleModelFromJson(
        Map<String, dynamic> json) =>
    ReservationScheduleModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ReservationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReservationScheduleModelToJson(
        ReservationScheduleModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

ReservationData _$ReservationDataFromJson(Map<String, dynamic> json) =>
    ReservationData(
      startDate: DateTime.parse(json['startDate'] as String),
      reservations: (json['reservations'] as List<dynamic>)
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReservationDataToJson(ReservationData instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'reservations': instance.reservations,
    };

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
      times: json['times'] as int,
      ticketType: json['ticketType'] as String,
      userNickname: json['userNickname'] as String,
      ticketStartedAt: json['ticketStartedAt'] as String,
      ticketExpiredAt: json['ticketExpiredAt'] as String,
      trainer: Trainer.fromJson(json['trainer'] as Map<String, dynamic>),
      seq: json['seq'] as int,
      totalSession: json['totalSession'] as int,
      selected: json['selected'] as bool? ?? false,
    );

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': instance.status,
      'times': instance.times,
      'ticketType': instance.ticketType,
      'userNickname': instance.userNickname,
      'ticketStartedAt': instance.ticketStartedAt,
      'ticketExpiredAt': instance.ticketExpiredAt,
      'trainer': instance.trainer,
      'seq': instance.seq,
      'totalSession': instance.totalSession,
      'selected': instance.selected,
    };

Trainer _$TrainerFromJson(Map<String, dynamic> json) => Trainer(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String,
    );

Map<String, dynamic> _$TrainerToJson(Trainer instance) => <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
    };
