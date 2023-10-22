import 'package:json_annotation/json_annotation.dart';

part 'notificatiion_main_state_model.g.dart';

abstract class NotificationMainModelBase {}

class NotificationMainModelError extends NotificationMainModelBase {
  final String message;

  NotificationMainModelError({
    required this.message,
  });
}

class NotificationMainModelLoading extends NotificationMainModelBase {}

@JsonSerializable()
class NotificationMainModel extends NotificationMainModelBase {
  bool isConfirmed;
  int threadBadgeCount;

  NotificationMainModel({
    required this.isConfirmed,
    required this.threadBadgeCount,
  });

  NotificationMainModel copyWith({
    bool? isConfirmed,
    int? threadBadgeCount,
  }) =>
      NotificationMainModel(
        isConfirmed: isConfirmed ?? this.isConfirmed,
        threadBadgeCount: threadBadgeCount ?? this.threadBadgeCount,
      );

  factory NotificationMainModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationMainModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationMainModelToJson(this);
}
