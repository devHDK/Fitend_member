import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/threads/thread_get_list_params_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_emoji_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadProvider =
    StateNotifierProvider<ThreadStateNotifier, ThreadListModelBase>((ref) {
  final threadRepository = ref.watch(threadRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);
  final emojiRepository = ref.watch(emojiRepositoryProvider);
  final dioUpload = ref.watch(dioUploadProvider);

  return ThreadStateNotifier(
    threadRepository: threadRepository,
    commentRepository: commentRepository,
    emojiRepository: emojiRepository,
    dioUpload: dioUpload,
  );
});

class ThreadStateNotifier extends StateNotifier<ThreadListModelBase> {
  final ThreadRepository threadRepository;
  final ThreadCommentRepository commentRepository;
  final EmojiRepository emojiRepository;
  final Dio dioUpload;

  ThreadStateNotifier({
    required this.threadRepository,
    required this.commentRepository,
    required this.emojiRepository,
    required this.dioUpload,
  }) : super(ThreadListModelLoading()) {
    paginate(startIndex: 0);
  }

  Future<void> paginate({
    required int startIndex,
    bool fetchMore = false,
    bool isRefetch = false,
  }) async {
    try {
      final isLoading = state is ThreadListModelLoading;
      final isRefetching = state is ThreadListModelRefetching;
      final isFetchMore = state is ThreadListModelFetchingMore;

      if (fetchMore && (isLoading || isFetchMore || isRefetching)) {
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as ThreadListModel;

        state =
            ThreadListModelFetchingMore(data: pState.data, total: pState.total);
      } else {
        if (state is ThreadListModel) {
          final pState = state as ThreadListModel;
          state =
              ThreadListModelRefetching(data: pState.data, total: pState.total);
        } else {
          state = ThreadListModelLoading();
        }
      }

      ThreadListModel? threadResponse;

      try {
        threadResponse = await threadRepository.getThreads(
            params: ThreadGetListParamsModel(start: startIndex, perPage: 15));
      } on DioException catch (e) {
        debugPrint('getWorkoutSchedule error : $e');
      }

      if (state is ThreadListModelFetchingMore && threadResponse != null) {
        final pState = state as ThreadListModel;

        state = ThreadListModel(data: <ThreadModel>[
          ...pState.data,
          ...threadResponse.data,
        ], total: pState.total);
      } else if (threadResponse != null) {
        final pstate = ThreadListModel(
            data: threadResponse.data, total: threadResponse.total);
        state = pstate;
      }
    } catch (e) {
      debugPrint('e : ScheduleModelError');
      state = ThreadListModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }
}
