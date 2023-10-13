import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_list_model.g.dart';

abstract class ThreadListModelBase {}

class ThreadListModelError extends ThreadListModelBase {
  final String message;

  ThreadListModelError({
    required this.message,
  });
}

class ThreadListModelLoading extends ThreadListModelBase {}

@JsonSerializable()
class ThreadListModel extends ThreadListModelBase {
  @JsonKey(name: "data")
  final List<ThreadModel> data;
  @JsonKey(name: "total")
  final int total;

  ThreadListModel({
    required this.data,
    required this.total,
  });

  ThreadListModel copyWith({
    List<ThreadModel>? data,
    int? total,
  }) =>
      ThreadListModel(
        data: data ?? this.data,
        total: total ?? this.total,
      );

  factory ThreadListModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadListModelToJson(this);
}

class ThreadListModelFetchingMore extends ThreadListModel {
  ThreadListModelFetchingMore({
    required super.data,
    required super.total,
  });
}

class ThreadListModelRefetching extends ThreadListModel {
  ThreadListModelRefetching({
    required super.data,
    required super.total,
  });
}
