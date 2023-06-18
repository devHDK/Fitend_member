import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutScheduleProvider = StateNotifierProvider.family<
    WorkoutScheduleStateNotifier,
    WorkoutScheduleModelBase,
    DateTime>((ref, startDate) {
  final repository = ref.watch(workoutScheduleRepositoryProvider);

  return WorkoutScheduleStateNotifier(
      repository: repository, startDate: startDate);
});

class WorkoutScheduleStateNotifier
    extends StateNotifier<WorkoutScheduleModelBase> {
  final WorkoutScheduleRepository repository;
  final DateTime startDate;

  WorkoutScheduleStateNotifier({
    required this.repository,
    required this.startDate,
  }) : super(WorkoutScheduleModelLoading()) {
    paginate(startDate: startDate);
  }

  Future<void> paginate({
    required DateTime startDate,
    bool fetchMore = false,
    bool isRefetch = false,
    bool isUpScrolling = false,
    bool isDownScrolling = false,
  }) async {
    try {
      final isLoading = state is WorkoutScheduleModelLoading;
      final isRefetching = state is WorkoutScheduleRefetching;
      final isFetchMore = state is WorkoutScheduleFetchingMore;

      if (fetchMore && (isLoading || isFetchMore || isRefetching)) {
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as WorkoutScheduleModel;

        state = WorkoutScheduleFetchingMore(
          data: pState.data,
        );
      } else if (isRefetch) {
      } else {
        // 데이터를 처음부터 가져오는 상황
        if (state is WorkoutScheduleModel) {
          final pState = state as WorkoutScheduleModel;
          state = WorkoutScheduleRefetching(data: pState.data);
        } else {
          state = WorkoutScheduleModelLoading();
        }
      }

      final response = await repository.getWorkoutSchedule(
        params: WorkoutSchedulePagenateParams(
          startDate: startDate,
        ),
      );

      List<WorkoutData> tempWorkoutList = List.generate(
        31,
        (index) => WorkoutData(
          startDate: startDate.add(Duration(days: index)),
          workouts: [],
        ),
      );

      int index = 0;

      if (response.data!.isNotEmpty) {
        for (var e in tempWorkoutList) {
          if (index >= response.data!.length) {
            break;
          }

          if (e.startDate.year == response.data![index].startDate.year &&
              e.startDate.month == response.data![index].startDate.month &&
              e.startDate.day == response.data![index].startDate.day) {
            e.workouts!.addAll(response.data![index].workouts!);

            if (e.startDate.year == DateTime.now().year &&
                e.startDate.month == DateTime.now().month &&
                e.startDate.day == DateTime.now().day) {
              e.workouts![0].selected = true;
            }
            index++;
          }
        }
      }

      if (state is WorkoutScheduleFetchingMore) {
        final pState = state as WorkoutScheduleFetchingMore;
        if (isUpScrolling) {
          state = WorkoutScheduleModel(data: <WorkoutData>[
            ...tempWorkoutList,
            ...pState.data!,
          ]);
        } else if (isDownScrolling) {
          state = WorkoutScheduleModel(data: <WorkoutData>[
            ...pState.data!,
            ...tempWorkoutList,
          ]);
        }
      } else {
        state = WorkoutScheduleModel(data: tempWorkoutList);
      }
    } catch (e) {
      state = WorkoutScheduleModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }

  void updateScheduleFromBuffer() {
    state = WorkoutScheduleModel(data: scheduleListGlobal);
  }

  void updateScheduleState(
      {required int workoutScheduleId, required DateTime startDate}) {
    //이전 스케줄 인덱스
    final beforeChangeScheduleIndex = scheduleListGlobal.indexWhere(
      (element) {
        return element.startDate == startDate;
      },
    );

    //이전 워크아웃 인덱스
    final beforWorkoutIndex = scheduleListGlobal[beforeChangeScheduleIndex]
        .workouts!
        .indexWhere(
            (element) => element.workoutScheduleId == workoutScheduleId);

    scheduleListGlobal[beforeChangeScheduleIndex].workouts![beforWorkoutIndex] =
        scheduleListGlobal[beforeChangeScheduleIndex]
            .workouts![beforWorkoutIndex]
            .copyWith(
              isComplete: true,
              isRecord: true,
            );
    state = WorkoutScheduleModel(data: scheduleListGlobal);
  }
}
