import 'package:fitend_member/trainer/model/trainer_list_model.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trainer_list_extend.g.dart';

abstract class TrainerListExtendBase {}

class TrainerListExtendError extends TrainerListExtendBase {
  final String message;

  TrainerListExtendError({
    required this.message,
  });
}

@JsonSerializable()
class TrainerListExtend extends TrainerListExtendBase {
  @JsonKey(name: "data")
  final List<TrainerInfomation> data;
  @JsonKey(name: "total")
  final int total;

  TrainerListExtend({
    required this.data,
    required this.total,
  });

  TrainerListExtend copyWith({
    List<TrainerInfomation>? data,
    int? total,
  }) =>
      TrainerListExtend(
        data: data ?? this.data,
        total: total ?? this.total,
      );

  factory TrainerListExtend.fromJson(Map<String, dynamic> json) =>
      _$TrainerListExtendFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerListExtendToJson(this);
}

class TrainerListExtendFetchingMore extends TrainerListExtend {
  TrainerListExtendFetchingMore({
    required super.data,
    required super.total,
  });
}

class TrainerListExtendRefetching extends TrainerListExtend {
  TrainerListExtendRefetching({
    required super.data,
    required super.total,
  });
}
