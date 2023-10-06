import 'package:json_annotation/json_annotation.dart';

part 'thread_comment_get_params_model.g.dart';

@JsonSerializable()
class CommentGetListParamsModel {
  @JsonKey(name: "threadId")
  final int threadId;

  CommentGetListParamsModel({
    required this.threadId,
  });

  CommentGetListParamsModel copyWith({
    int? threadId,
  }) =>
      CommentGetListParamsModel(
        threadId: threadId ?? this.threadId,
      );

  factory CommentGetListParamsModel.fromJson(Map<String, dynamic> json) =>
      _$CommentGetListParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentGetListParamsModelToJson(this);
}
