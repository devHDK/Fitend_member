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
    initialFetch(startDate: startDate);
  }

  initialFetch({
    required DateTime startDate,
    bool fetchMore = false,
  }) async {
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

    state = WorkoutScheduleModel(data: tempWorkoutList);
  }
}
