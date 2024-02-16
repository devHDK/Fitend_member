// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_list_extend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerListExtend _$TrainerListExtendFromJson(Map<String, dynamic> json) =>
    TrainerListExtend(
      data: (json['data'] as List<dynamic>)
          .map((e) => TrainerInfomation.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$TrainerListExtendToJson(TrainerListExtend instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
    };
