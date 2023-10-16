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
    List<EmojiModel>? emojis,
    required ThreadUser user,
  }) {
    final pstate = state as ThreadModel;

    pstate.comments ??= [];

    final tempComments = [
      ...pstate.comments!,
      ThreadCommentModel(
        id: id,
        threadId: threadId,
        content: content,
        createdAt: createdAt,
        gallery: gallery,
        emojis: emojis,
        user: user,
      ),
    ];

    print(tempComments);

    pstate.comments = tempComments;

    state = pstate;
  }

  Future<Map<dynamic, dynamic>> updateThreadEmoji(
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
          addThreadEmoji(userId, inputEmoji, response.emojiId);
          result['type'] = 'add';
        } else {
          //이모지 취소
          removeThreadEmoji(userId, inputEmoji, response.emojiId);
          result['type'] = 'remove';
        }
      } else if (pstate.emojis != null && pstate.emojis!.isEmpty) {
        addThreadEmoji(userId, inputEmoji, response.emojiId);
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

  Future<Map<dynamic, dynamic>> updateCommentEmoji(
      int commentId, int userId, String inputEmoji) async {
    try {
      final pstate = state as ThreadModel;

      final response = await emojiRepository.putEmoji(
        model: PutEmojiParamsModel(
          emoji: inputEmoji,
          commentId: commentId,
        ),
      );

      final commentIndex =
          pstate.comments!.indexWhere((e) => e.id == commentId);

      Map result = {'type': 'add', 'emojiId': 0};

      if (pstate.comments!.isNotEmpty) {
        final emojiIndex =
            pstate.comments![commentIndex].emojis!.indexWhere((emoji) {
          return emoji.emoji == inputEmoji && emoji.userId == userId;
        });
        if (emojiIndex == -1) {
          //이모지 추가
          addCommentEmoji(userId, inputEmoji, commentIndex, response.emojiId);
          result['type'] = 'add';
        } else {
          //이모지 취소
          removeCommentEmoji(
              userId, inputEmoji, commentIndex, response.emojiId);
          result['type'] = 'remove';
        }
      }

      result['emojiId'] = response.emojiId;

      state = pstate;

      return result;
    } catch (e) {
      debugPrint('$e');
      return {'type': 'error'};
    }
  }

  void addThreadEmoji(int userId, String inputEmoji, int emojiId) {
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

  void removeThreadEmoji(int userId, String inputEmoji, int emojiId) {
    final pstate = state as ThreadModel;
    pstate.emojis!.removeWhere((emoji) {
      return emoji.id == emojiId && emoji.userId == userId;
    });

    state = pstate.copyWith();
  }

  void addCommentEmoji(int userId, String inputEmoji, int index, int emojiId) {
    final pstate = state as ThreadModel;

    pstate.comments![index].emojis!.add(
      EmojiModel(
        id: emojiId,
        emoji: inputEmoji,
        userId: userId,
        trainerId: null,
      ),
    );

    state = pstate.copyWith();
  }

  void removeCommentEmoji(
      int userId, String inputEmoji, int index, int emojiId) {
    final pstate = state as ThreadModel;
    pstate.comments![index].emojis!.removeWhere((emoji) {
      return emoji.id == emojiId && emoji.userId == userId;
    });

    state = pstate.copyWith();
  }
}
