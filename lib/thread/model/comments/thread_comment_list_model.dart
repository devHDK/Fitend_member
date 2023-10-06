import 'package:fitend_member/thread/model/comments/thread_comment_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_comment_list_model.g.dart';

@JsonSerializable()
class ThreadCommentListModel {
  @JsonKey(name: "data")
  final List<ThreadCommentModel> data;

  ThreadCommentListModel({
    required this.data,
  });

  ThreadCommentListModel copyWith({
    List<ThreadCommentModel>? data,
  }) =>
      ThreadCommentListModel(
        data: data ?? this.data,
      );

  factory ThreadCommentListModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadCommentListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadCommentListModelToJson(this);
}
