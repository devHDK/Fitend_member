import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_emoji_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
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
  }) : super(ThreadListModelLoading());

  Future<void> uploadFileToS3({required String url, dynamic file}) async {
    await dioUpload.patch(
      url,
      data: file,
    );
  }
}
