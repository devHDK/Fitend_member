import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/provider/workout_records_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutProcessProvider = StateNotifierProvider.family<
    WorkoutProcessStateNotifier, WorkoutModelBase, int>((ref, id) {
  final repository = ref.watch(workoutScheduleRepositoryProvider);
  AsyncValue<Box> workoutRecordBox = ref.read(hiveWorkoutRecordProvider);

  return WorkoutProcessStateNotifier(
    repository: repository,
    id: id,
    workoutRecordBox: workoutRecordBox,
  );
});

class WorkoutProcessStateNotifier extends StateNotifier<WorkoutModelBase> {
  final WorkoutScheduleRepository repository;
  final int id;
  final AsyncValue<Box> workoutRecordBox;

  WorkoutProcessStateNotifier({
    required this.repository,
    required this.id,
    required this.workoutRecordBox,
  }) : super(WorkoutModelLoading());
}
