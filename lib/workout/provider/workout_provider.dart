import 'package:dio/dio.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutProvider =
    StateNotifierProvider.family<WorkoutStateNotifier, WorkoutModelBase, int>(
        (ref, id) {
  final repository = ref.watch(workoutScheduleRepositoryProvider);

  return WorkoutStateNotifier(repository: repository, id: id);
});

class WorkoutStateNotifier extends StateNotifier<WorkoutModelBase> {
  final WorkoutScheduleRepository repository;
  final int id;

  WorkoutStateNotifier({
    required this.repository,
    required this.id,
  }) : super(WorkoutModelLoading()) {
    getWorkout(id: id);
  }

  Future<void> getWorkout({required int id}) async {
    try {
      final response = await repository.getWorkout(id: id);

      state = response;
    } on DioError {
      state = WorkoutModelError(message: '데이터를 불러올수없습니다');
    }
  }

  void updateWorkoutStateDate({
    required String dateTime,
  }) {
    final pstate = state as WorkoutModel;

    state = pstate.copyWith(startDate: dateTime);
  }

  void updateWorkoutStateIsComplete() {
    if (state is WorkoutModelLoading) {
      return;
    }

    final pstate = state as WorkoutModel;

    state = pstate.copyWith(isWorkoutComplete: true);
  }
}
