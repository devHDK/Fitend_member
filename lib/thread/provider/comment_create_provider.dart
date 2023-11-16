import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_create_model.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/exception/exceptios.dart';
import 'package:fitend_member/thread/model/files/file_upload_request_model.dart';
import 'package:fitend_member/thread/model/threads/thread_comment_edit_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/repository/file_repository.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
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
            emojis: [],
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
      emojis: [],
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
        final isOverLimtSize = await DataUtils.checkFileSize(state.assetsPaths);

        if (isOverLimtSize) {
          throw UploadException(message: 'oversize_file_include_error');
        }

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

            final retVideo = await fileRepository.getFileUpload(
              model: FileRequestModel(type: 'video', mimeType: mimeType!),
            );

            await VideoCompress.setLogLevel(0);
            final mediaInfo = await VideoCompress.compressVideo(
              filePath,
              quality: VideoQuality.Res1280x720Quality,
              includeAudio: true,
            );

            File file;
            if (mediaInfo != null && mediaInfo.file != null) {
              file = mediaInfo.file!;
            } else {
              file = File(filePath);
            }

            final thumbnail = await MediaUtils.getVideoThumbNail(file.path);
            final thumbnailMimeType = mime(thumbnail);

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

            if (mediaInfo != null) {
              final compressFile = File(mediaInfo.path!);
              if (await compressFile.exists()) await compressFile.delete();
            }
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
        emojis: [],
        user: user,
      );

      threadListState.updateUserCommentCount(threadId, 1);

      init();

      if (state.assetsPaths.isNotEmpty) {
        DialogWidgets.showToast('업로드가 완료되었습니다!');
      }
    } catch (e) {
      debugPrint('comment create error : $e');
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
            themeColor: Pallete.point,
            maxAssets: maxAssets,
            loadingIndicatorBuilder: (context, isAssetsEmpty) => const Center(
              child: CircularProgressIndicator(
                color: Pallete.point,
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

  Future<void> updateFromEditModel(ThreadCommentEditModel editModel) async {
    List<String> assetPaths = [];

    if (editModel.gallery != null && editModel.gallery!.isNotEmpty) {
      for (var asset in editModel.gallery!) {
        final fileInfo = await DefaultCacheManager()
            .getFileFromCache('${URLConstants.s3Url}${asset.url}');

        if (fileInfo != null) {
          assetPaths.add(fileInfo.file.path);
        } else {
          debugPrint('media 다운로드중...');
          final file = await DefaultCacheManager().getSingleFile(
              '${URLConstants.s3Url}${asset.url}',
              key: '${URLConstants.s3Url}${asset.url}');

          assetPaths.add(file.path);
        }
      }
    }

    state = ThreadCommentCreateTempModel(
      threadId: threadId,
      content: editModel.content,
      isLoading: false,
      isUploading: false,
      doneCount: 0,
      totalCount: assetPaths.length,
      assetsPaths: assetPaths,
      isEditedAssets: List.generate(assetPaths.length, (index) => false),
      gallery: editModel.gallery,
      emojis: [],
    );
  }

  Future<ThreadCommentCreateModel?> updateComment(
    int commentId,
    List<GalleryModel>? gallery,
  ) async {
    try {
      if (state.isUploading || state.isLoading) {
        return null;
      }

      final pstate = state.copyWith();
      pstate.isUploading = true;

      state = pstate;

      ThreadCommentCreateModel model = ThreadCommentCreateModel(
        content: state.content,
        gallery: [],
      );

      List<GalleryModel> addGallery = [];

      if (state.assetsPaths.isNotEmpty && state.isEditedAssets != null) {
        final isOverLimtSize = await DataUtils.checkFileSize(state.assetsPaths);

        if (isOverLimtSize) {
          throw UploadException(message: 'oversize_file_include_error');
        }

        final tempState0 = state.copyWith();
        tempState0.totalCount =
            state.isEditedAssets!.where((element) => true).length;
        state = tempState0;

        for (int index = 0; index < state.assetsPaths.length; index++) {
          final filePath = state.assetsPaths[index];

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

            final retVideo = await fileRepository.getFileUpload(
              model: FileRequestModel(type: 'video', mimeType: mimeType!),
            );

            await VideoCompress.setLogLevel(0);
            final mediaInfo = await VideoCompress.compressVideo(
              filePath,
              quality: VideoQuality.Res1280x720Quality,
              includeAudio: true,
            );

            File file;
            if (mediaInfo != null && mediaInfo.file != null) {
              file = mediaInfo.file!;
            } else {
              file = File(filePath);
            }

            final thumbnail = await MediaUtils.getVideoThumbNail(file.path);
            final thumbnailMimeType = mime(thumbnail);

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

            if (mediaInfo != null) {
              final compressFile = File(mediaInfo.path!);
              if (await compressFile.exists()) await compressFile.delete();
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

      await commentRepository.putCommentWithId(id: commentId, model: model);

      threadState.updateComment(
        commentId,
        model,
      );

      init();

      DialogWidgets.showToast('수정이 완료되었습니다!');

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

  void addAssets(String assetPath) {
    final pstate = state.copyWith();

    pstate.assetsPaths.add(assetPath);

    state = pstate.copyWith();
  }

  void removeAsset(int index) {
    final pstate = state.copyWith();

    pstate.assetsPaths.removeAt(index);

    state = pstate.copyWith();
  }

  void changeAsset(int index, String path) {
    final pstate = state.copyWith();

    pstate.assetsPaths[index] = path;

    state = pstate.copyWith();
  }

  void updateIsLoading(bool isLoading) {
    final pstate = state.copyWith();

    pstate.isLoading = isLoading;

    state = pstate.copyWith();
  }

  void updateContent(String content) {
    final pstate = state.copyWith();

    pstate.content = content;

    state = pstate.copyWith();
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
