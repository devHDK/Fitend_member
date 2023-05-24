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
    bool isUpScrolling = false,
    bool isDownScrolling = false,
  }) async {
    try {
      final isLoading = state is WorkoutScheduleModelLoading;
      final isFetchMore = state is WorkoutScheduleFetchingMore;

      print('fetchMore : $fetchMore');
      print('isLoading : $isLoading');
      print('isFetchMore : $isFetchMore');

      if (fetchMore && (isLoading || isFetchMore)) {
        print('========================= retun!!=========================');
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as WorkoutScheduleModel;

        state = WorkoutScheduleFetchingMore(
          data: pState.data,
        );
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
        tempWorkoutList.map(
          (e) {
            if (index == response.data!.length) {
              return false;
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
          },
        ).toList();
      }

      if (state is WorkoutScheduleFetchingMore) {
        final pState = state as WorkoutScheduleFetchingMore;
        if (isUpScrolling) {
          print(
              '======================upscroll fetching=======================');
          state = WorkoutScheduleModel(data: [
            ...tempWorkoutList,
            ...pState.data!,
          ]);
          print(state);
        } else if (isDownScrolling) {
          print(
              '======================downscroll fetching=======================');
          state = response.copyWith(
            data: [
              ...pState.data!,
              ...tempWorkoutList,
            ],
          );
          print(state);
        }
      } else {
        state = WorkoutScheduleModel(data: tempWorkoutList);
      }
    } catch (e) {
      state = WorkoutScheduleModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }
}
