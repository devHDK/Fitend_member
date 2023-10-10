import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadCreateProvider =
    StateNotifierProvider<ThreadCreateStateNotifier, ThreadCreateTempModel>(
        (ref) {
  final threadRepository = ref.watch(threadRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);
  final dioUpload = ref.watch(dioUploadProvider);

  return ThreadCreateStateNotifier(
    threadRepository: threadRepository,
    commentRepository: commentRepository,
    dioUpload: dioUpload,
  );
});

class ThreadCreateStateNotifier extends StateNotifier<ThreadCreateTempModel> {
  final ThreadRepository threadRepository;
  final ThreadCommentRepository commentRepository;
  final Dio dioUpload;

  ThreadCreateStateNotifier({
    required this.threadRepository,
    required this.commentRepository,
    required this.dioUpload,
  }) : super(ThreadCreateTempModel()) {
    init();
  }

  void init() {
    state = ThreadCreateTempModel(
      assetsPaths: [],
    );
  }

  void addAssets(String assetPath) {
    state.assetsPaths!.add(assetPath);
  }

  void removeAsset(int index) {
    final pstate = state;

    print('index $index');

    pstate.assetsPaths!.removeAt(index);

    state = pstate;
  }

  void changeAsset(int index, String path) {
    final pstate = state;

    pstate.assetsPaths![index] = path;

    state = pstate;
  }
}
