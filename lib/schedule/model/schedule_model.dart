import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

abstract class ScheduleModelBase {}

class ScheduleModelError extends ScheduleModelBase {
  final String message;

  ScheduleModelError({
    required this.message,
  });
}

class ScheduleModelLoading extends ScheduleModelBase {}

@JsonSerializable()
class ScheduleModel extends ScheduleModelBase {
  final List<ScheduleData> data;
  int? scrollIndex;
  bool? isNeedMeeing;

  ScheduleModel({
    required this.data,
    this.scrollIndex,
    this.isNeedMeeing,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJSon() => _$ScheduleModelToJson(this);
}

class ScheduleModelFetchingMore extends ScheduleModel {
  ScheduleModelFetchingMore({
    required super.data,
    super.scrollIndex,
    super.isNeedMeeing,
  });
}

class ScheduleModelRefetching extends ScheduleModel {
  ScheduleModelRefetching({
    required super.data,
    super.scrollIndex,
    super.isNeedMeeing,
  });
}

@JsonSerializable()
class ScheduleData {
  final DateTime startDate;
  List<dynamic>? schedule;

  ScheduleData({
    required this.startDate,
    this.schedule,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDataFromJson(json);

  Map<String, dynamic> toJSon() => _$ScheduleDataToJson(this);
}
