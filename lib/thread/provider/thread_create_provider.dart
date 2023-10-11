import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/dio/dio_upload.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/repository/thread_comment_repository.dart';
import 'package:fitend_member/thread/repository/thread_repository.dart';
import 'package:fitend_member/thread/view/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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

  Future<List<AssetEntity>?> pickImage(BuildContext context) async {
    try {
      final permission = await AssetPicker.permissionCheck();

      print(permission.hasAccess);

      if (!permission.hasAccess) {
        openAppSettings();
        return null;
      } else {
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
      print(e);
      return null;
    }
  }

  Future<void> pickCamera(BuildContext context) async {
    try {
      bool isGotPermission = false;

      if (Platform.isAndroid) {
        if (await Permission.storage.request().isGranted) {
          isGotPermission = true;
        }
      } else if (Platform.isIOS) {
        if (await Permission.photos.request().isGranted) {
          isGotPermission = true;
        }
      }

      if (isGotPermission) {
        openAppSettings();
      }

      final directory = await createAlbum('Fitend');

      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) =>
              CustomCameraScreen(diretoryPath: directory.path),
        ),
      );
    } catch (e) {
      print(e);
    }
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

  Future<Directory> createAlbum(String albumName) async {
    final extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/$albumName';

    final savedDir = Directory(dirPath);

    bool hasExisted = await savedDir.exists();

    print('hasExisted ===> $hasExisted');

    if (!hasExisted) {
      await savedDir.create();
    }

    return savedDir;
  }
}
