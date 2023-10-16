import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_get_params_model.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_model.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_params_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_emoji_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadDetailProvider = StateNotifierProvider.family<
    ThreadDetailStateNotifier, ThreadModelBase, int>((ref, threadId) {
  final threadRepository = ref.watch(threadRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);
  final emojiRepository = ref.watch(emojiRepositoryProvider);
  final dioUpload = ref.watch(dioUploadProvider);

  return ThreadDetailStateNotifier(
    threadId: threadId,
    threadRepository: threadRepository,
    commentRepository: commentRepository,
    emojiRepository: emojiRepository,
    dioUpload: dioUpload,
  );
});

class ThreadDetailStateNotifier extends StateNotifier<ThreadModelBase> {
  final int threadId;
  final ThreadRepository threadRepository;
  final ThreadCommentRepository commentRepository;
  final EmojiRepository emojiRepository;
  final Dio dioUpload;

  ThreadDetailStateNotifier({
    required this.threadId,
    required this.threadRepository,
    required this.commentRepository,
    required this.emojiRepository,
    required this.dioUpload,
  }) : super(ThreadModelLoading()) {
    getThreadDetail(threadId: threadId);
  }

  Future<void> getThreadDetail({required int threadId}) async {
    try {
      var thread = await threadRepository.getThreadWithId(id: threadId);
      var comments = await commentRepository.getComments(
          model: CommentGetListParamsModel(threadId: threadId));

      thread.comments = comments.data;

      state = thread.copyWith();
    } catch (e) {
      debugPrint('$e');
      state = ThreadModelError(message: '데이터를 불러올수 없습니다');
    }
  }

  void addComment({
    required int id,
    required String content,
    required String createdAt,
    List<GalleryModel>? gallery,
    required ThreadUser user,
  }) {
    final pstate = state as ThreadModel;

    pstate.comments ??= [];

    final tempComments = [
      ThreadCommentModel(
        id: id,
        threadId: threadId,
        content: content,
        createdAt: createdAt,
        gallery: gallery,
        user: user,
      ),
      ...pstate.comments!,
    ];

    print(tempComments);

    pstate.comments = tempComments;

    state = pstate;
  }

  Future<Map<dynamic, dynamic>> updateEmoji(
      int threadId, int userId, String inputEmoji) async {
    try {
      final pstate = state as ThreadModel;

      final response = await emojiRepository.putEmoji(
        model: PutEmojiParamsModel(
          emoji: inputEmoji,
          threadId: threadId,
        ),
      );

      Map result = {'type': 'add', 'emojiId': 0};

      if (pstate.emojis != null && pstate.emojis!.isNotEmpty) {
        final emojiIndex = pstate.emojis!.indexWhere((emoji) {
          return emoji.emoji == inputEmoji && emoji.userId == userId;
        });
        if (emojiIndex == -1) {
          //이모지 추가
          addEmoji(userId, inputEmoji, response.emojiId);
          result['type'] = 'add';
        } else {
          //이모지 취소
          removeEmoji(userId, inputEmoji, response.emojiId);
          result['type'] = 'remove';
        }
      } else if (pstate.emojis != null && pstate.emojis!.isEmpty) {
        addEmoji(userId, inputEmoji, response.emojiId);
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

  void addEmoji(int userId, String inputEmoji, int emojiId) {
    final pstate = state as ThreadModel;

    pstate.emojis!.add(
      EmojiModel(
        id: emojiId,
        emoji: inputEmoji,
        userId: userId,
        trainerId: null,
      ),
    );

    state = pstate.copyWith();
  }

  void removeEmoji(int userId, String inputEmoji, int emojiId) {
    final pstate = state as ThreadModel;
    pstate.emojis!.removeWhere((emoji) {
      return emoji.id == emojiId && emoji.userId == userId;
    });

    state = pstate.copyWith();
  }
}
