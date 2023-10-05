import 'package:json_annotation/json_annotation.dart';

part 'thread_get_list_params_model.g.dart';

@JsonSerializable()
class ThreadGetListParamsModel {
  @JsonKey(name: "start")
  final int start;
  @JsonKey(name: "perpage")
  final int perpage;

  ThreadGetListParamsModel({
    required this.start,
    required this.perpage,
  });

  ThreadGetListParamsModel copyWith({
    int? start,
    int? perpage,
  }) =>
      ThreadGetListParamsModel(
        start: start ?? this.start,
        perpage: perpage ?? this.perpage,
      );

  factory ThreadGetListParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadGetListParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadGetListParamsModelToJson(this);
}
