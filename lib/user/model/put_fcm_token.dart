import 'package:json_annotation/json_annotation.dart';

part 'put_fcm_token.g.dart';

@JsonSerializable()
class PutFcmToken {
  @JsonKey(name: "deviceId")
  final String deviceId;
  @JsonKey(name: "token")
  final String token;
  @JsonKey(name: "platform")
  final String platform;

  PutFcmToken({
    required this.deviceId,
    required this.token,
    required this.platform,
  });

  PutFcmToken copyWith({
    String? deviceId,
    String? token,
    String? platform,
  }) =>
      PutFcmToken(
        deviceId: deviceId ?? this.deviceId,
        token: token ?? this.token,
        platform: platform ?? this.platform,
      );

  factory PutFcmToken.fromJson(Map<String, dynamic> json) =>
      _$PutFcmTokenFromJson(json);

  Map<String, dynamic> toJson() => _$PutFcmTokenToJson(this);
}
