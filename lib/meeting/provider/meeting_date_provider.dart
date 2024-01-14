import 'package:collection/collection.dart';
import 'package:fitend_member/meeting/model/meeting_date_model.dart';
import 'package:fitend_member/meeting/model/post_meeting_create_model.dart';
import 'package:fitend_member/meeting/repository/meeting_repository.dart';
import 'package:fitend_member/trainer/model/get_trainer_schedule_model.dart';
import 'package:fitend_member/trainer/repository/trainer_repository.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final meetingDateProvider = StateNotifierProvider.family<
    MeetingDateStateNotifier, MeetingDateModelBase?, int>((ref, trainerId) {
  final trainerRepository = ref.watch(trainerRepositoryProvider);
  final meetingRepository = ref.watch(meetingRepositoryProvider);
  final user = ref.watch(getMeProvider);

  return MeetingDateStateNotifier(
    trainerId: trainerId,
    trainerRepository: trainerRepository,
    meetingRepository: meetingRepository,
    user: user as UserModel,
  );
});

class MeetingDateStateNotifier extends StateNotifier<MeetingDateModelBase?> {
  final int trainerId;
  final TrainerRepository trainerRepository;
  final MeetingRepository meetingRepository;
  final UserModel user;

  MeetingDateStateNotifier({
    required this.trainerId,
    required this.trainerRepository,
    required this.meetingRepository,
    required this.user,
  }) : super(null) {
    // final now = DateTime.now();
    // final today = DateTime(now.year, now.month, now.day);
    // final endDate = today.add(const Duration(days: 5));

    // getTrainerSchedules(
    //   trainerId,
    //   GetTrainerScheduleModel(
    //     startDate: today,
    //     endDate: endDate,
    //   ),
    // );
  }

  Future<void> getTrainerSchedules(
      int trainerId, GetTrainerScheduleModel model) async {
    try {
      if (state is MeetingDateModelLoading) return;

      state = MeetingDateModelLoading();

      final trainerWorkStartTime =
          user.user.activeTrainers.first.workStartTime.split(':');
      final trainerWorkEndTime =
          user.user.activeTrainers.first.workEndTime.split(':');

      MeetingDateModel ret = MeetingDateModel(data: []);
      final days = model.endDate.difference(model.startDate).inDays + 1;

      for (int index = 0; index < days; index++) {
        DateTime start = DateTime(
          model.startDate.year,
          model.startDate.month,
          model.startDate.day + index,
          int.parse(trainerWorkStartTime[0]),
          int.parse(trainerWorkStartTime[1]),
        );

        DateTime end = DateTime(
          model.startDate.year,
          model.startDate.month,
          model.startDate.day + index,
          int.parse(trainerWorkEndTime[0]),
          int.parse(trainerWorkEndTime[1]),
        );
        List<TrainerSchedule> slots = [];

        for (int i = 0;
            start.add(Duration(minutes: 30 * i)).isBefore(end);
            i++) {
          slots.add(TrainerSchedule(
            endTime: start.add(Duration(minutes: (30 * i) + 15)),
            startTime: start.add(Duration(minutes: 30 * i)),
            type: 'meeting',
            isAvail: true,
          ));
        }

        ScheduleData data = ScheduleData(
          startDate: model.startDate.add(Duration(days: index)),
          schedules: slots,
        );

        ret.data.add(data);
      }

      final serverData = await trainerRepository.getTrainerSchedules(
        id: trainerId,
        model: model,
      );

      for (var scheduleData in ret.data) {
        final serverIndex = serverData.data.indexWhere(
          (element) => element.startDate == scheduleData.startDate,
        );

        if (serverIndex != -1) {
          final trainerSchedule = serverData.data[serverIndex].schedules;

          for (var schedule in scheduleData.schedules) {
            for (var trainerSchedule in trainerSchedule) {
              if ((schedule.startTime.isBefore(trainerSchedule.endTime) &&
                      schedule.endTime.isAfter(trainerSchedule.startTime)) ||
                  schedule.startTime
                      .isBefore(DateTime.now().add(const Duration(hours: 1)))) {
                schedule.isAvail = false;
              }
            }
          }
        }
      }

      state = ret;
    } catch (e) {
      state = MeetingDateModelError(message: e.toString());
    }
  }

  Future<void> createMeeting(PostMeetingCreateModel model) async {
    try {
      await meetingRepository.meetingCreate(model: model);
    } catch (e) {
      rethrow;
    }
  }
}
