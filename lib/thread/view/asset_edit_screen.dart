import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/thread/component/edit_video_player.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/video_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:line_icons/line_icons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

class AssetEditScreen extends ConsumerStatefulWidget {
  const AssetEditScreen({
    super.key,
    required this.pageIndex,
    this.parentUpdate,
  });
  final int pageIndex;
  final Function? parentUpdate;

  @override
  ConsumerState<AssetEditScreen> createState() => _AssetEditScreenState();
}

class _AssetEditScreenState extends ConsumerState<AssetEditScreen> {
  int fileIndex = 0;
  PageController? _pageController;
  bool? pause;

  @override
  void initState() {
    super.initState();
    fileIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);
  }

  @override
  void dispose() {
    _pageController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadCreateProvider);

    final intPath = utf8.encode(state.assetsPaths![fileIndex]);
    final path = Uint8List.fromList(intPath);
    final file = File.fromRawPath(path);
    final type = MediaUtils.getMediaType(file.path);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100.w,
            height: 100.h - kToolbarHeight - 70,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                return type == MediaType.image
                    ? _editImageView(file, state)
                    : EditVideoPlayer(
                        file: file,
                      );
              },
              itemCount: state.assetsPaths!.length,
              onPageChanged: (value) => setState(
                () {
                  fileIndex = value;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _editImageView(File file, ThreadCreateTempModel state) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            child: Center(
              child: Image.file(
                file,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  final croppedFile = await ImageCropper().cropImage(
                    sourcePath: state.assetsPaths![fileIndex],
                    compressFormat: ImageCompressFormat.jpg,
                    compressQuality: 100,
                    uiSettings: [
                      AndroidUiSettings(
                        toolbarTitle: '',
                        toolbarColor: BACKGROUND_COLOR,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false,
                      ),
                      IOSUiSettings(
                        title: '',
                        doneButtonTitle: '저장',
                        cancelButtonTitle: '취소',
                        resetButtonHidden: true,
                      ),
                    ],
                  );

                  if (croppedFile != null) {
                    setState(() {
                      state.assetsPaths![fileIndex] = croppedFile.path;
                    });
                    if (widget.parentUpdate != null) {
                      widget.parentUpdate!();
                    }
                  }
                },
                icon: const Icon(
                  Icons.crop,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
