import 'package:fitend_member/workout/model/get_workout_history_params.dart';
import 'package:fitend_member/workout/model/workout_history_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutHistoryProvider = StateNotifierProvider.family<
    WorkoutHistoryStateNotifier, WorkoutHistoryModelBase, int>((ref, id) {
  final repository = ref.watch(workoutRecordsRepositoryProvider);

  return WorkoutHistoryStateNotifier(repository: repository, workoutPlanId: id);
});

class WorkoutHistoryStateNotifier
    extends StateNotifier<WorkoutHistoryModelBase> {
  final WorkoutRecordsRepository repository;
  final int workoutPlanId;

  WorkoutHistoryStateNotifier({
    required this.repository,
    required this.workoutPlanId,
  }) : super(WorkoutHistoryModelLoading()) {
    paginate();
  }

  Future<void> paginate({
    int? start = 0,
    bool fetchMore = false,
  }) async {
    try {
      final isLoading = state is WorkoutHistoryModelLoading;
      final isFetchMore = state is WorkoutHistoryModelFetchingMore;

      if (fetchMore && (isLoading || isFetchMore)) {
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as WorkoutHistoryModel;

        state = WorkoutHistoryModelFetchingMore(
          data: pState.data,
          total: pState.total,
        );
      }

      final response = await repository.getWorkoutHistory(
        params: GetWorkoutHistoryParams(
          workoutPlanId: workoutPlanId,
          start: start!,
          perPage: 20,
        ),
      );

      if (state is WorkoutHistoryModelFetchingMore) {
        final pState = state as WorkoutHistoryModel;

        state = pState.copyWith(
          data: <HistoryData>[
            ...pState.data,
            ...response.data,
          ],
        );
      } else {
        state = WorkoutHistoryModel(data: response.data, total: response.total);
      }
    } catch (e) {
      debugPrint('$e');
      state = WorkoutHistoryModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }
}
