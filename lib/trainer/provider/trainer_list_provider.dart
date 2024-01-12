import 'package:fitend_member/trainer/model/trainer_list_model.dart';
import 'package:fitend_member/trainer/repository/trainer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trainerListProvider =
    StateNotifierProvider<TrainerListStateNotifier, TrainerListModelBase>(
        (ref) {
  final repository = ref.watch(trainerRepositoryProvider);

  return TrainerListStateNotifier(repository: repository);
});

class TrainerListStateNotifier extends StateNotifier<TrainerListModelBase> {
  final TrainerRepository repository;

  TrainerListStateNotifier({
    required this.repository,
  }) : super(TrainerListModelLoading()) {
    getTrainers();
  }

  Future<void> getTrainers() async {
    try {
      final ret = await repository.getTrainers();

      state = ret;
    } catch (e) {
      state = TrainerListModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }
}
