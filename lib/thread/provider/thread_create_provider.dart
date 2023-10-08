import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadDetailProvider =
    StateNotifierProvider<ThreadDetailStateNotifier, ThreadCreateTempModel>(
        (ref) {
  final threadRepository = ref.watch(threadRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);
  final dioUpload = ref.watch(dioUploadProvider);

  return ThreadDetailStateNotifier(
    threadRepository: threadRepository,
    commentRepository: commentRepository,
    dioUpload: dioUpload,
  );
});

class ThreadDetailStateNotifier extends StateNotifier<ThreadCreateTempModel> {
  final ThreadRepository threadRepository;
  final ThreadCommentRepository commentRepository;
  final Dio dioUpload;

  ThreadDetailStateNotifier({
    required this.threadRepository,
    required this.commentRepository,
    required this.dioUpload,
  }) : super(ThreadCreateTempModel());
}
