import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final List<NotificationData> data;
  final int total;

  NotificationModel({
    required this.data,
    required this.total,
  });

  NotificationModel copyWith({
    List<NotificationData>? data,
    int? total,
  }) =>
      NotificationModel(
        data: data ?? this.data,
        total: total ?? this.total,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class NotificationData {
  final int id;
  final String type;
  final String contents;
  Info? info;
  final bool isConfirm;
  final String createdAt;

  NotificationData({
    required this.id,
    required this.type,
    required this.contents,
    this.info,
    required this.isConfirm,
    required this.createdAt,
  });

  NotificationData copyWith({
    int? id,
    String? type,
    String? contents,
    Info? info,
    bool? isConfirm,
    String? createdAt,
  }) =>
      NotificationData(
        id: id ?? this.id,
        type: type ?? this.type,
        contents: contents ?? this.contents,
        info: info ?? this.info,
        isConfirm: isConfirm ?? this.isConfirm,
        createdAt: createdAt ?? this.createdAt,
      );

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}

@JsonSerializable()
class Info {
  Info();

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);

  Map<String, dynamic> toJson() => _$InfoToJson(this);
}
