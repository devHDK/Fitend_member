import 'package:json_annotation/json_annotation.dart';

part 'notification_setting_model.g.dart';

@JsonSerializable()
class NotificationSettingParams {
  final bool isNotification;

  NotificationSettingParams({
    required this.isNotification,
  });

  NotificationSettingParams copyWith({
    bool? isNotification,
  }) =>
      NotificationSettingParams(
        isNotification: isNotification ?? this.isNotification,
      );

  factory NotificationSettingParams.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingParamsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingParamsToJson(this);
}
