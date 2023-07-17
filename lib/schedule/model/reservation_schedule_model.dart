import 'package:json_annotation/json_annotation.dart';
part 'reservation_schedule_model.g.dart';

@JsonSerializable()
class ReservationScheduleModel {
  final List<ReservationData>? data;

  ReservationScheduleModel({
    required this.data,
  });

  ReservationScheduleModel copyWith({
    List<ReservationData>? data,
  }) =>
      ReservationScheduleModel(
        data: data ?? this.data,
      );

  factory ReservationScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationScheduleModelFromJson(json);

  Map<String, dynamic> toJSon() => _$ReservationScheduleModelToJson(this);
}

@JsonSerializable()
class ReservationData {
  final DateTime startDate;
  final List<Reservation> reservations;

  ReservationData({
    required this.startDate,
    required this.reservations,
  });

  ReservationData copyWith({
    DateTime? startDate,
    List<Reservation>? reservations,
  }) =>
      ReservationData(
        startDate: startDate ?? this.startDate,
        reservations: reservations ?? this.reservations,
      );

  factory ReservationData.fromJson(Map<String, dynamic> json) =>
      _$ReservationDataFromJson(json);

  Map<String, dynamic> toJSon() => _$ReservationDataToJson(this);
}

@JsonSerializable()
class Reservation {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String ticketType;
  final String userNickname;
  final String ticketStartedAt;
  final String ticketExpiredAt;
  final Trainer trainer;
  final int seq;
  final int totalSession;

  Reservation({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.ticketType,
    required this.userNickname,
    required this.ticketStartedAt,
    required this.ticketExpiredAt,
    required this.trainer,
    required this.seq,
    required this.totalSession,
  });

  Reservation copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? ticketType,
    String? userNickname,
    String? ticketStartedAt,
    String? ticketExpiredAt,
    Trainer? trainer,
    int? seq,
    int? totalSession,
  }) =>
      Reservation(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        ticketType: ticketType ?? this.ticketType,
        userNickname: userNickname ?? this.userNickname,
        ticketStartedAt: ticketStartedAt ?? this.ticketStartedAt,
        ticketExpiredAt: ticketExpiredAt ?? this.ticketExpiredAt,
        trainer: trainer ?? this.trainer,
        seq: seq ?? this.seq,
        totalSession: totalSession ?? this.totalSession,
      );

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  Map<String, dynamic> toJSon() => _$ReservationToJson(this);
}

@JsonSerializable()
class Trainer {
  final int id;
  final String nickname;
  final String profileImage;

  Trainer({
    required this.id,
    required this.nickname,
    required this.profileImage,
  });

  Trainer copyWith({
    int? id,
    String? nickname,
    String? profileImage,
  }) =>
      Trainer(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        profileImage: profileImage ?? this.profileImage,
      );

  factory Trainer.fromJson(Map<String, dynamic> json) =>
      _$TrainerFromJson(json);

  Map<String, dynamic> toJSon() => _$TrainerToJson(this);
}
