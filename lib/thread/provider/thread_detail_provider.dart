import 'package:fitend_member/thread/model/thread_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadDetailProvider = StateNotifierProvider.family<
    ThreadDetailStateNotifier, ThreadModelBase, int>((ref, id) {
  final threadRepository = ref.watch(threadRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);

  return ThreadDetailStateNotifier(
    threadRepository: threadRepository,
    commentRepository: commentRepository,
  );
});

class ThreadDetailStateNotifier extends StateNotifier<ThreadModelBase> {
  final ThreadRepository threadRepository;
  final ThreadCommentRepository commentRepository;

  ThreadDetailStateNotifier(
      {required this.threadRepository, required this.commentRepository})
      : super(ThreadModelLoading());
}
