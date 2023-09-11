import 'package:dio/dio.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/schedule/model/reservation_schedule_model.dart';
import 'package:fitend_member/schedule/model/schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:fitend_member/schedule/repository/reservation_schedule_repository.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleProvider =
    StateNotifierProvider<ScheduleStateNotifier, ScheduleModelBase>((ref) {
  final workoutRepository = ref.watch(workoutScheduleRepositoryProvider);
  final reservationRepository = ref.watch(reservaionScheduleRepositoryProvider);

  return ScheduleStateNotifier(
    workoutRepository: workoutRepository,
    reservationRepository: reservationRepository,
  );
});

class ScheduleStateNotifier extends StateNotifier<ScheduleModelBase> {
  final WorkoutScheduleRepository workoutRepository;
  final ReservationScheduleRepository reservationRepository;

  ScheduleStateNotifier({
    required this.workoutRepository,
    required this.reservationRepository,
  }) : super(ScheduleModelLoading());
  // {
  //   // paginate(startDate: startDate);
  // }

  Future<void> paginate({
    required DateTime startDate,
    bool fetchMore = false,
    bool isRefetch = false,
    bool isUpScrolling = false,
    bool isDownScrolling = false,
  }) async {
    try {
      final isLoading = state is ScheduleModelLoading;
      final isRefetching = state is ScheduleModelRefetching;
      final isFetchMore = state is ScheduleModelFetchingMore;

      if (fetchMore && (isLoading || isFetchMore || isRefetching)) {
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as ScheduleModel;

        state = ScheduleModelFetchingMore(data: pState.data);
      } else {
        if (state is ScheduleModel) {
          final pState = state as ScheduleModel;
          state = ScheduleModelRefetching(data: pState.data);
        } else {
          state = ScheduleModelLoading();
        }
      }
      ReservationScheduleModel? reservationResponse;
      try {
        reservationResponse =
            await reservationRepository.getReservationSchedule(
          params: SchedulePagenateParams(
            startDate: startDate,
            interval: 30,
          ),
        );
      } on DioException catch (e) {
        debugPrint('getReservationSchedule error : $e');
      }

      WorkoutScheduleModel? workoutResponse;

      try {
        workoutResponse = await workoutRepository.getWorkoutSchedule(
          params: SchedulePagenateParams(
            startDate: startDate,
            interval: 30,
          ),
        );
      } on DioException catch (e) {
        debugPrint('getWorkoutSchedule error : $e');
      }

      List<ScheduleData> tempScheduleList = List.generate(
        31,
        (index) => ScheduleData(
          startDate: startDate.add(Duration(days: index)),
          schedule: [],
        ),
      );

      int index = 0;

      if (reservationResponse != null &&
          reservationResponse.data != null &&
          reservationResponse.data!.isNotEmpty) {
        for (var e in tempScheduleList) {
          if (index >= reservationResponse.data!.length) {
            break;
          }

          if (e.startDate.year ==
                  reservationResponse.data![index].startDate.year &&
              e.startDate.month ==
                  reservationResponse.data![index].startDate.month &&
              e.startDate.day ==
                  reservationResponse.data![index].startDate.day) {
            e.schedule!.addAll(reservationResponse.data![index].reservations);

            if (e.startDate.year == DateTime.now().year &&
                e.startDate.month == DateTime.now().month &&
                e.startDate.day == DateTime.now().day &&
                e.schedule![0] is Reservation) {
              e.schedule![0].selected = true;
            }
            index++;
          }
        }
      }

      index = 0;

      if (workoutResponse != null &&
          workoutResponse.data != null &&
          workoutResponse.data!.isNotEmpty) {
        for (var e in tempScheduleList) {
          if (index >= workoutResponse.data!.length) {
            break;
          }

          if (e.startDate.year == workoutResponse.data![index].startDate.year &&
              e.startDate.month ==
                  workoutResponse.data![index].startDate.month &&
              e.startDate.day == workoutResponse.data![index].startDate.day) {
            e.schedule!.addAll(workoutResponse.data![index].workouts!);

            if (e.startDate.year == DateTime.now().year &&
                e.startDate.month == DateTime.now().month &&
                e.startDate.day == DateTime.now().day &&
                e.schedule![0] is Workout) {
              e.schedule![0].selected = true;
            }
            index++;
          }
        }
      }

      if (state is ScheduleModelFetchingMore) {
        final pState = state as ScheduleModel;
        if (isUpScrolling) {
          state = ScheduleModel(data: <ScheduleData>[
            ...tempScheduleList,
            ...pState.data,
          ]);
        } else if (isDownScrolling) {
          state = ScheduleModel(data: <ScheduleData>[
            ...pState.data,
            ...tempScheduleList,
          ]);
        }
      } else {
        state = ScheduleModel(data: tempScheduleList);
        if (state is ScheduleModel) {
          final pstate = state as ScheduleModel;
          scheduleListGlobal = pstate.data;
        }
      }
    } catch (e) {
      debugPrint('e : ScheduleModelError');
      state = ScheduleModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }

  void updateScheduleFromBuffer() {
    state = ScheduleModel(data: scheduleListGlobal);
  }

  void updateScheduleState({
    required int workoutScheduleId,
    required DateTime startDate,
  }) {
    //이전 스케줄 인덱스
    final beforeChangeScheduleIndex = scheduleListGlobal.indexWhere(
      (element) {
        return element.startDate == startDate;
      },
    );

    //이전 워크아웃 인덱스
    final beforWorkoutIndex = scheduleListGlobal[beforeChangeScheduleIndex]
        .schedule!
        .indexWhere((element) {
      if (element is Workout) {
        return element.workoutScheduleId == workoutScheduleId;
      }

      return false;
    });

    scheduleListGlobal[beforeChangeScheduleIndex].schedule![beforWorkoutIndex] =
        scheduleListGlobal[beforeChangeScheduleIndex]
            .schedule![beforWorkoutIndex]
            .copyWith(
              isComplete: true,
              isRecord: true,
            );
    state = ScheduleModel(data: scheduleListGlobal);
  }
}
