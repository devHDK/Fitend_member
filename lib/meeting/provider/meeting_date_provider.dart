import 'package:fitend_member/meeting/model/meeting_date_model.dart';
import 'package:fitend_member/trainer/model/get_trainer_schedule_model.dart';
import 'package:fitend_member/trainer/repository/trainer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final meetingDateProvider = StateNotifierProvider.family<
    MeetingDateStateNotifier, MeetingDateModelBase?, int>((ref, trainerId) {
  final repository = ref.watch(trainerRepositoryProvider);

  return MeetingDateStateNotifier(trainerId: trainerId, repository: repository);
});

class MeetingDateStateNotifier extends StateNotifier<MeetingDateModelBase?> {
  final int trainerId;
  final TrainerRepository repository;

  MeetingDateStateNotifier({
    required this.trainerId,
    required this.repository,
  }) : super(MeetingDateModelLoading()) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.add(const Duration(days: 5));

    getTrainerSchedules(
      trainerId,
      GetTrainerScheduleModel(
        startDate: today,
        endDate: endDate,
      ),
    );
  }

  Future<void> getTrainerSchedules(
      int trainerId, GetTrainerScheduleModel model) async {
    try {
      state = MeetingDateModelLoading();

      final trainerSchedule =
          await repository.getTrainerSchedules(id: trainerId, model: model);

      state = trainerSchedule.copyWith();
    } catch (e) {
      state = MeetingDateModelError(message: e.toString());
    }
  }
}
