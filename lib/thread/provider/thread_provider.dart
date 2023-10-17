import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_params_model.dart';
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

        state = ThreadListModel(
          data: <ThreadModel>[
            ...pState.data,
            ...threadResponse.data,
          ],
          total: threadResponse.total,
        );
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

  void addThread(ThreadModel model) {
    final pstate = state as ThreadListModel;

    final tempList = [model, ...pstate.data];

    pstate.data = tempList;
    pstate.total += 1;

    state = pstate.copyWith();
  }

  void updateUserCommentCount(int threadId, int count) {
    final pstate = state as ThreadListModel;

    int index = pstate.data.indexWhere(
      (thread) {
        return thread.id == threadId;
      },
    );

    pstate.data[index].userCommentCount =
        pstate.data[index].userCommentCount! + count;

    state = pstate.copyWith();
  }

  Future<Map<dynamic, dynamic>> updateEmoji(
      int threadId, int userId, String inputEmoji) async {
    try {
      final pstate = state as ThreadListModel;

      Map result = {'type': 'add', 'emojiId': 0};

      int index = pstate.data.indexWhere(
        (thread) {
          return thread.id == threadId;
        },
      );

      final response = await emojiRepository.putEmoji(
        model: PutEmojiParamsModel(
          emoji: inputEmoji,
          threadId: threadId,
        ),
      );

      if (pstate.data[index].emojis != null &&
          pstate.data[index].emojis!.isNotEmpty) {
        final emojiIndex = pstate.data[index].emojis!.indexWhere((emoji) {
          return emoji.emoji == inputEmoji && emoji.userId == userId;
        });

        //TODO: threadDetail emoji 추가 삭제
        if (emojiIndex == -1) {
          //이모지 추가
          addEmoji(userId, inputEmoji, index, response.emojiId);
          result['type'] = 'add';
        } else {
          //이모지 취소
          removeEmoji(userId, inputEmoji, index, response.emojiId);
          result['type'] = 'remove';
        }
      } else if (pstate.data[index].emojis != null &&
          pstate.data[index].emojis!.isEmpty) {
        addEmoji(userId, inputEmoji, index, response.emojiId);
        result['type'] = 'add';
      }

      result['emojiId'] = response.emojiId;

      state = pstate;

      return result;
    } catch (e) {
      debugPrint('$e');

      return {'type': 'error'};
    }
  }

  void addEmoji(int userId, String inputEmoji, int index, int emojiId) {
    final pstate = state as ThreadListModel;

    pstate.data[index].emojis!.add(
      EmojiModel(
        id: emojiId,
        emoji: inputEmoji,
        userId: userId,
        trainerId: null,
      ),
    );

    state = pstate.copyWith();
  }

  void removeEmoji(int userId, String inputEmoji, int index, int emojiId) {
    final pstate = state as ThreadListModel;
    pstate.data[index].emojis!.removeWhere((emoji) {
      return emoji.id == emojiId && emoji.userId == userId;
    });

    state = pstate.copyWith();
  }

  void removeThreadWithId(int threadId, int index) {
    final pstate = state as ThreadListModel;

    pstate.data.removeAt(index);

    state = pstate.copyWith();
  }
}
