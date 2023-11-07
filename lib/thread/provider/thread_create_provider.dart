import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/exception/exceptios.dart';
import 'package:fitend_member/thread/model/files/file_upload_request_model.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/model/threads/thread_edit_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/repository/file_repository.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
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

  void updateFromCache(ThreadCreateTempModel model) {
    state = ThreadCreateTempModel(
      isLoading: false,
      isUploading: false,
      content: model.content,
      title: model.title,
      doneCount: 0,
      totalCount: 0,
      assetsPaths: model.assetsPaths,
      trainerId: model.trainerId,
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
        final isOverLimtSize =
            await DataUtils.checkFileSize(state.assetsPaths!);

        if (isOverLimtSize) {
          throw UploadException(message: 'oversize_file_include_error');
        }

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
            try {
              final mimeType = mime(filePath);

              final thumbnail = await MediaUtils.getVideoThumbNail(filePath);
              final thumbnailMimeType = mime(thumbnail);

              final retVideo = await fileRepository.getFileUpload(
                model: FileRequestModel(type: 'video', mimeType: mimeType!),
              );

              debugPrint('압축 시작 ===> ${DateTime.now()}');
              await VideoCompress.setLogLevel(0);
              final mediaInfo = await VideoCompress.compressVideo(
                filePath,
                quality: VideoQuality.Res1280x720Quality,
                includeAudio: true,
              );
              debugPrint('압축 종료 ===> ${DateTime.now()}');

              File file;
              if (mediaInfo != null && mediaInfo.file != null) {
                file = mediaInfo.file!;
              } else {
                file = File(filePath);
              }

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
                model: FileRequestModel(
                    type: 'image', mimeType: thumbnailMimeType!),
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

              if (mediaInfo != null) {
                final compressFile = File(mediaInfo.path!);

                if (await compressFile.exists()) {
                  await compressFile.delete();
                  print('압축파일 삭제');
                }
              }
            } catch (e) {
              debugPrint('video upload error ===> $e');
              throw UploadException(message: 'error');
            }
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
          comments: [],
        ),
      );

      init();
    } catch (e) {
      final tstate = state.copyWith();
      tstate.isUploading = false;
      state = tstate;

      if (e is UploadException) {
        debugPrint('thread create error : ${e.message}');
        throw UploadException(message: e.message);
      } else {
        throw CommonException(message: '$e');
      }
    }
  }

  Future<List<AssetEntity>?> pickImage(
      BuildContext context, int maxAssets) async {
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
            maxAssets: maxAssets,
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

  Future<void> updateFromEditModel(ThreadEditModel editModel) async {
    List<String> assetPaths = [];

    if (editModel.gallery != null && editModel.gallery!.isNotEmpty) {
      for (var asset in editModel.gallery!) {
        final fileInfo =
            await DefaultCacheManager().getFileFromCache('$s3Url${asset.url}');

        if (fileInfo != null) {
          assetPaths.add(fileInfo.file.path);
        } else {
          debugPrint('media 다운로드중...');
          final file = await DefaultCacheManager()
              .getSingleFile('$s3Url${asset.url}', key: '$s3Url${asset.url}');

          assetPaths.add(file.path);
        }
      }
    }

    state = ThreadCreateTempModel(
      title: editModel.title,
      content: editModel.content,
      isLoading: false,
      isUploading: false,
      doneCount: 0,
      totalCount: assetPaths.length,
      assetsPaths: assetPaths,
      isEditedAssets: List.generate(assetPaths.length, (index) => false),
      gallery: editModel.gallery,
    );
  }

  Future<ThreadCreateModel?> updateThread(
    ThreadUser user,
    ThreadTrainer trainer,
    int threadId,
    List<GalleryModel>? gallery,
  ) async {
    try {
      if (state.isUploading || state.isLoading) {
        return null;
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

      List<GalleryModel> addGallery = [];

      if (state.assetsPaths != null &&
          state.assetsPaths!.isNotEmpty &&
          state.isEditedAssets != null) {
        final isOverLimtSize =
            await DataUtils.checkFileSize(state.assetsPaths!);

        if (isOverLimtSize) {
          throw UploadException(message: 'oversize_file_include_error');
        }

        final tempState0 = state.copyWith();
        tempState0.totalCount =
            state.isEditedAssets!.where((element) => true).length;
        state = tempState0;

        for (int index = 0; index < state.assetsPaths!.length; index++) {
          final filePath = state.assetsPaths![index];
          final type = MediaUtils.getMediaType(filePath);

          if (type == MediaType.image &&
              state.isEditedAssets != null &&
              state.isEditedAssets![index]) {
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

            if (state.gallery!.length < index + 1) {
              addGallery.add(
                GalleryModel(type: 'image', url: ret.path),
              );
            } else {
              state.gallery![index] =
                  GalleryModel(type: 'image', url: ret.path);
            }
          } else if (type == MediaType.video &&
              state.isEditedAssets != null &&
              state.isEditedAssets![index]) {
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

            if (state.gallery!.length < index + 1) {
              addGallery.add(
                GalleryModel(
                  type: 'video',
                  url: retVideo.path,
                  thumbnail: retThumbnail.path,
                ),
              );
            } else {
              state.gallery![index] = GalleryModel(
                type: 'video',
                url: retVideo.path,
                thumbnail: retThumbnail.path,
              );
            }
          }

          final tempState1 = state.copyWith();

          tempState1.doneCount++;

          state = tempState1;
        }
      }

      model.gallery = [
        ...state.gallery!,
        ...addGallery,
      ];

      await threadRepository.putThreadWithId(id: threadId, model: model);

      init();

      return model;
    } catch (e) {
      debugPrint('thread create error : $e');
      final tstate = state.copyWith();
      tstate.isUploading = false;
      state = tstate;

      if (e is UploadException) {
        debugPrint('thread create error : ${e.message}');
        throw UploadException(message: e.message);
      } else {
        throw CommonException(message: '$e');
      }
    }
  }

  void updateFileCheck(String type, int index) {
    final pstate = state.copyWith();

    switch (type) {
      case 'add':
        pstate.isEditedAssets!.add(true);

        break;
      case 'remove':
        pstate.isEditedAssets!.removeAt(index);
        break;
      case 'change':
        pstate.isEditedAssets![index] = true;
        break;
    }

    state = pstate.copyWith();
  }

  void removeAssetFromGallery(int index) {
    final pstate = state.copyWith(
      gallery: state.gallery!.map((e) => e.copyWith()).toList(),
    );

    if (pstate.gallery != null &&
        pstate.gallery!.isNotEmpty &&
        pstate.gallery!.length >= index + 1) {
      pstate.gallery!.removeAt(index);
    }

    state = pstate.copyWith();
  }
}
