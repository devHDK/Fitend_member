import 'package:fitend_member/trainer/model/get_extend_trainers_model.dart';
import 'package:fitend_member/trainer/model/trainer_list_extend.dart';
import 'package:fitend_member/trainer/repository/trainer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trainerListExtendProvider = StateNotifierProvider.autoDispose<
    TrainerListExtendStateNotifier, TrainerListExtendBase>((ref) {
  final repository = ref.watch(trainerRepositoryProvider);

  return TrainerListExtendStateNotifier(repository: repository);
});

class TrainerListExtendStateNotifier
    extends StateNotifier<TrainerListExtendBase> {
  final TrainerRepository repository;

  TrainerListExtendStateNotifier({
    required this.repository,
  }) : super(TrainerListExtend(data: [], total: 0));

  Future<void> paginate({
    int? start = 0,
    String? search,
    bool fetchMore = false,
    bool isRefetch = false,
  }) async {
    try {
      final isRefetching = state is TrainerListExtendRefetching;
      final isFetchMore = state is TrainerListExtendFetchingMore;

      if (fetchMore && (isFetchMore || isRefetching)) {
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as TrainerListExtend;

        state = TrainerListExtendFetchingMore(
          data: pState.data,
          total: pState.total,
        );
      } else {
        if (state is TrainerListExtend) {
          final pState = state as TrainerListExtend;
          state = TrainerListExtendRefetching(
              data: pState.data, total: pState.total);
        }
      }

      final ret = await repository.getTrainersExtend(GetExtendTrainersModel(
        start: start!,
        perPage: 20,
        search: search,
      ));

      if (state is TrainerListExtendFetchingMore) {
        final pState = state as TrainerListExtend;

        state = pState.copyWith(
          data: [
            ...pState.data,
            ...ret.data,
          ],
        );
      } else {
        state = ret;
      }
    } catch (e) {
      print(e);

      state = TrainerListExtendError(message: '데이터를 불러오지 못했습니다.');
    }
  }

  void init() {
    state = TrainerListExtend(data: [], total: 0);
  }
}
