import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/files/file_upload_request_model.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/repository/file_repository.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path_provider/path_provider.dart';

final threadCreateProvider =
    StateNotifierProvider<ThreadCreateStateNotifier, ThreadCreateTempModel>(
        (ref) {
  final threadRepository = ref.watch(threadRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);
  final fileRepository = ref.watch(fileRepositoryProvider);
  final dioUpload = ref.watch(dioUploadProvider);
  final threadListState = ref.watch(threadProvider.notifier);

  return ThreadCreateStateNotifier(
    threadRepository: threadRepository,
    commentRepository: commentRepository,
    fileRepository: fileRepository,
    dioUpload: dioUpload,
    threadListState: threadListState,
  );
});

class ThreadCreateStateNotifier extends StateNotifier<ThreadCreateTempModel> {
  final ThreadRepository threadRepository;
  final ThreadCommentRepository commentRepository;
  final FileRepository fileRepository;
  final Dio dioUpload;
  final ThreadStateNotifier threadListState;

  ThreadCreateStateNotifier({
    required this.threadRepository,
    required this.commentRepository,
    required this.fileRepository,
    required this.dioUpload,
    required this.threadListState,
  }) : super(
          ThreadCreateTempModel(
            isLoading: false,
            isUploading: false,
            content: '',
            doneCount: 0,
            totalCount: 0,
            assetsPaths: [],
          ),
        ) {
    init();
  }

  void init() {
    state = ThreadCreateTempModel(
      assetsPaths: [],
      isLoading: false,
      isUploading: false,
      content: '',
      doneCount: 0,
      totalCount: 0,
    );
  }

  Future<void> createThread(
    ThreadUser user,
    ThreadTrainer trainer,
  ) async {
    try {
      if (state.isUploading || state.isLoading) {
        return;
      }

      final pstate = state.copyWith();
      pstate.isUploading = true;

      state = pstate;

      ThreadCreateModel model = ThreadCreateModel(
        trainerId: trainer.id,
        title: state.title != null && state.title!.isNotEmpty
            ? state.title!
            : null,
        content: state.content,
        gallery: [],
      );

      if (state.assetsPaths != null && state.assetsPaths!.isNotEmpty) {
        final tempState0 = state.copyWith();

        tempState0.totalCount = state.assetsPaths!.length;

        state = tempState0;

        for (var filePath in state.assetsPaths!) {
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

      final response = await threadRepository.postThread(model: model);

      threadListState.addThread(
        ThreadModel(
          id: response.id,
          writerType: 'user',
          type: 'general',
          title: model.title,
          content: model.content,
          gallery: model.gallery,
          workoutInfo: null,
          user: user,
          trainer: trainer,
          emojis: [],
          createdAt: DateTime.now().toUtc().toIso8601String(),
          userCommentCount: 0,
          trainerCommentCount: 0,
        ),
      );

      init();
    } catch (e) {
      debugPrint('thread create error : $e');
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
          builder: (context) => const CameraScreen(),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addAssets(String assetPath) {
    final pstate = state.copyWith();

    pstate.assetsPaths!.add(assetPath);

    state = pstate;
  }

  void removeAsset(int index) {
    final pstate = state.copyWith();

    pstate.assetsPaths!.removeAt(index);

    state = pstate;
  }

  void changeAsset(int index, String path) {
    final pstate = state.copyWith();

    pstate.assetsPaths![index] = path;

    state = pstate;
  }

  void updateIsLoading(bool isLoading) {
    final pstate = state.copyWith();

    pstate.isLoading = isLoading;

    state = pstate;
  }

  void updateTitle(String? title) {
    final pstate = state.copyWith();

    pstate.title = title;

    state = pstate;
  }

  void updateContent(String content) {
    final pstate = state.copyWith();

    pstate.content = content;

    state = pstate;
  }

  Future<Directory> createAlbum(String albumName) async {
    final extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/$albumName';

    final savedDir = Directory(dirPath);

    bool hasExisted = await savedDir.exists();

    if (!hasExisted) {
      await savedDir.create();
    }

    return savedDir;
  }
}
