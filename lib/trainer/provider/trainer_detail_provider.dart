import 'package:fitend_member/trainer/model/trainer_detail_model.dart';
import 'package:fitend_member/trainer/repository/trainer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trainerDetailProvider = StateNotifierProvider.family<TrainerStateNotifier,
    TrainerDetailModelBase, int>((ref, id) {
  final repository = ref.watch(trainerRepositoryProvider);

  return TrainerStateNotifier(id: id, repository: repository);
});

class TrainerStateNotifier extends StateNotifier<TrainerDetailModelBase> {
  final int id;
  final TrainerRepository repository;

  TrainerStateNotifier({
    required this.id,
    required this.repository,
  }) : super(TrainerDetailModelLoading()) {
    getTrainerDetail(id);
  }

  Future<void> getTrainerDetail(int trainerId) async {
    try {
      final ret = await repository.getTrainerDetail(id: trainerId);

      state = ret;
    } catch (e) {
      state = TrainerDetailModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }
}
