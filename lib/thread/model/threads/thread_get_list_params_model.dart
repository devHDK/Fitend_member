import 'package:json_annotation/json_annotation.dart';

part 'thread_get_list_params_model.g.dart';

@JsonSerializable()
class ThreadGetListParamsModel {
  @JsonKey(name: "start")
  final int start;
  @JsonKey(name: "perPage")
  final int perPage;

  ThreadGetListParamsModel({
    required this.start,
    required this.perPage,
  });

  ThreadGetListParamsModel copyWith({
    int? start,
    int? perpage,
  }) =>
      ThreadGetListParamsModel(
        start: start ?? this.start,
        perPage: perpage ?? perPage,
      );

  factory ThreadGetListParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadGetListParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadGetListParamsModelToJson(this);
}
