// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      workoutPlanId: json['workoutPlanId'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      trackingFieldId: json['trackingFieldId'] as int,
      trainerNickname: json['trainerNickname'] as String,
      trainerProfileImage: json['trainerProfileImage'] as String,
      targetMuscles: (json['targetMuscles'] as List<dynamic>)
          .map((e) => TargetMuscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => ExerciseVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      setInfo: (json['setInfo'] as List<dynamic>)
          .map((e) => SetInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'workoutPlanId': instance.workoutPlanId,
      'name': instance.name,
      'description': instance.description,
      'trackingFieldId': instance.trackingFieldId,
      'trainerNickname': instance.trainerNickname,
      'trainerProfileImage': instance.trainerProfileImage,
      'targetMuscles': instance.targetMuscles,
      'videos': instance.videos,
      'setInfo': instance.setInfo,
    };
