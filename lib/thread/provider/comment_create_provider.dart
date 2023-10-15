import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_create_model.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/files/file_upload_request_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/repository/file_repository.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

final commentCreateProvider = StateNotifierProvider.family<
    CommentCreateStateNotifier,
    ThreadCommentCreateTempModel,
    int>((ref, threadId) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  final fileRepository = ref.watch(fileRepositoryProvider);
  final dioUpload = ref.watch(dioUploadProvider);
  final threadState = ref.watch(threadDetailProvider(threadId).notifier);
  final threadListState = ref.watch(threadProvider.notifier);

  return CommentCreateStateNotifier(
    threadId: threadId,
    commentRepository: commentRepository,
    fileRepository: fileRepository,
    dioUpload: dioUpload,
    threadState: threadState,
    threadListState: threadListState,
  );
});

class CommentCreateStateNotifier
    extends StateNotifier<ThreadCommentCreateTempModel> {
  int threadId;
  final ThreadCommentRepository commentRepository;
  final FileRepository fileRepository;
  final Dio dioUpload;
  ThreadDetailStateNotifier threadState;
  ThreadStateNotifier threadListState;

  CommentCreateStateNotifier({
    required this.threadId,
    required this.commentRepository,
    required this.fileRepository,
    required this.dioUpload,
    required this.threadState,
    required this.threadListState,
  }) : super(
          ThreadCommentCreateTempModel(
            isLoading: false,
            isUploading: false,
            content: '',
            threadId: threadId,
            assetsPaths: [],
            doneCount: 0,
            totalCount: 0,
          ),
        ) {
    init();
  }

  void init() {
    state = ThreadCommentCreateTempModel(
      isLoading: false,
      isUploading: false,
      content: '',
      threadId: threadId,
      doneCount: 0,
      totalCount: 0,
      assetsPaths: [],
    );
  }

  Future<void> createComment(int threadId, ThreadUser user) async {
    try {
      if (state.isUploading || state.isLoading) {
        return;
      }

      final pstate = state.copyWith();
      pstate.isUploading = true;

      state = pstate;

      ThreadCommentCreateModel model = ThreadCommentCreateModel(
        threadId: threadId,
        content: state.content,
        gallery: [],
      );

      if (state.assetsPaths.isNotEmpty) {
        final tempState0 = state.copyWith();

        tempState0.totalCount = state.assetsPaths.length;

        state = tempState0;

        for (var filePath in state.assetsPaths) {
          final type = MediaUtils.getMediaType(filePath);

          if (type == MediaType.image) {
            final mimeType = mime(filePath);
            final ret = await fileRepository.getFileUpload(
              model: FileRequestModel(type: 'image', mimeType: mimeType!),
            );

            final file = File(filePath);
            final bytes = await file.readAsBytes();

            await dioUpload.put(
              ret.url,
              data: bytes,
              options: Options(
                headers: {
                  "Content-Type": mimeType,
                },
              ),
            );

            model.gallery!.add(
              GalleryModel(
                type: 'image',
                url: ret.path,
              ),
            );
          } else if (type == MediaType.video) {
            final mimeType = mime(filePath);

            final thumbnail = await MediaUtils.getVideoThumbNail(filePath);
            final thumbnailMimeType = mime(thumbnail);

            final retVideo = await fileRepository.getFileUpload(
              model: FileRequestModel(type: 'video', mimeType: mimeType!),
            );

            final file = File(filePath);
            final bytes = await file.readAsBytes();

            await dioUpload.put(
              retVideo.url,
              data: bytes,
              options: Options(
                headers: {
                  "Content-Type": mimeType,
                },
              ),
            );

            final retThumbnail = await fileRepository.getFileUpload(
              model:
                  FileRequestModel(type: 'image', mimeType: thumbnailMimeType!),
            );

            final thumbnailFile = File(thumbnail!);
            final thumbnailBytes = await thumbnailFile.readAsBytes();

            await dioUpload.put(
              retThumbnail.url,
              data: thumbnailBytes,
              options: Options(
                headers: {
                  "Content-Type": thumbnailMimeType,
                },
              ),
            );

            model.gallery!.add(
              GalleryModel(
                type: 'video',
                url: retVideo.path,
                thumbnail: retThumbnail.path,
              ),
            );
          }

          final tempState1 = state.copyWith();

          tempState1.doneCount++;

          state = tempState1;
        }
      }

      final respone = await commentRepository.postComment(model: model);

      threadState.addComment(
        id: respone.id,
        content: model.content,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        gallery: model.gallery,
        user: user,
      );

      threadListState.updateUserCommentCount(threadId);

      init();
    } catch (e) {
      debugPrint('comment create error : $e');
      final tstate = state.copyWith();
      tstate.isUploading = false;
      state = tstate;
    }
  }

  Future<List<AssetEntity>?> pickImage(BuildContext context) async {
    try {
      final permission = await AssetPicker.permissionCheck();

      if (!permission.hasAccess) {
        openAppSettings();
        return null;
      } else {
        // ignore: use_build_context_synchronously
        final result = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            themeColor: POINT_COLOR,
            maxAssets: 10,
            loadingIndicatorBuilder: (context, isAssetsEmpty) => const Center(
              child: CircularProgressIndicator(
                color: POINT_COLOR,
              ),
            ),
          ),
        );

        if (result != null && result.isNotEmpty) {
          return result;
        } else {
          return null;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> pickCamera(BuildContext context) async {
    try {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => CameraScreen(
            isComment: true,
            threadId: threadId,
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addAssets(String assetPath) {
    final pstate = state.copyWith();

    pstate.assetsPaths.add(assetPath);

    print(pstate.assetsPaths);
    print('asset length ${pstate.assetsPaths.length}');

    state = pstate.copyWith();
  }

  void removeAsset(int index) {
    final pstate = state.copyWith();

    pstate.assetsPaths.removeAt(index);

    state = pstate;
  }

  void changeAsset(int index, String path) {
    print(state.assetsPaths);
    final pstate = state.copyWith();

    pstate.assetsPaths[index] = path;

    state = pstate;
  }

  void updateIsLoading(bool isLoading) {
    final pstate = state.copyWith();

    pstate.isLoading = isLoading;

    state = pstate;
  }

  void updateContent(String content) {
    final pstate = state.copyWith();

    pstate.content = content;

    state = pstate;
  }
}
