import 'package:json_annotation/json_annotation.dart';

part 'notification_confirm_model.g.dart';

@JsonSerializable()
class NotificationConfirmResponse {
  final bool isConfirm;

  NotificationConfirmResponse({
    required this.isConfirm,
  });

  NotificationConfirmResponse copyWith({
    bool? isConfirm,
  }) =>
      NotificationConfirmResponse(
        isConfirm: isConfirm ?? this.isConfirm,
      );

  factory NotificationConfirmResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationConfirmResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationConfirmResponseToJson(this);
}

@JsonSerializable()
class NotificationConfirmParams {
  final int start;
  final int perPage;

  NotificationConfirmParams({
    required this.start,
    required this.perPage,
  });

  NotificationConfirmParams copyWith({
    int? start,
    int? perPage,
  }) =>
      NotificationConfirmParams(
        start: start ?? this.start,
        perPage: perPage ?? this.perPage,
      );

  factory NotificationConfirmParams.fromJson(Map<String, dynamic> json) =>
      _$NotificationConfirmParamsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationConfirmParamsToJson(this);
}
