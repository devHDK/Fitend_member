import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/thread/component/edit_video_player.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_create_model.dart';
import 'package:fitend_member/thread/provider/comment_create_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CommentAssetEditScreen extends ConsumerStatefulWidget {
  const CommentAssetEditScreen({
    super.key,
    required this.pageIndex,
    required this.threadId,
  });
  final int pageIndex;
  final int threadId;

  @override
  ConsumerState<CommentAssetEditScreen> createState() =>
      _AssetEditScreenState();
}

class _AssetEditScreenState extends ConsumerState<CommentAssetEditScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();

  int fileIndex = 0;
  PageController? _pageController;

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
    final state = ref.watch(commentCreateProvider(widget.threadId));

    final intPath = utf8.encode(state.assetsPaths[fileIndex]);
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
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100.w,
            height: 85.h - kToolbarHeight - 70,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                return type == MediaType.image
                    ? _editImageView(file, state)
                    : EditVideoPlayer(
                        file: file,
                        index: index,
                      );
              },
              itemCount: state.assetsPaths.length,
              onPageChanged: (value) {
                debugPrint('value : $value');

                setState(
                  () {
                    itemScrollController.jumpTo(index: value);
                    fileIndex = value;
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 10.h,
            child: ScrollablePositionedList.builder(
              scrollDirection: Axis.horizontal,
              itemScrollController: itemScrollController,
              initialScrollIndex: fileIndex,
              itemBuilder: (context, index) {
                final intPath = utf8.encode(state.assetsPaths[index]);
                final path = Uint8List.fromList(intPath);
                final file = File.fromRawPath(path);
                final type = MediaUtils.getMediaType(file.path);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      fileIndex = index;
                      _pageController!.jumpToPage(
                        index,
                      );
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: type == MediaType.image
                        ? PreviewImage(
                            file: file,
                            isCircle: false,
                            isBorder: fileIndex == index,
                            width: 100,
                          )
                        : PreviewVideoThumbNail(
                            file: file,
                            isCircle: false,
                            isBorder: fileIndex == index,
                            width: 100,
                          ),
                  ),
                );
              },
              itemCount: state.assetsPaths.length,
            ),
          )
        ],
      ),
    );
  }

  Column _editImageView(File file, ThreadCommentCreateTempModel state) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            child: Center(
              child: Hero(
                tag: file.path,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                ),
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
                    sourcePath: state.assetsPaths[fileIndex],
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
                    ref
                        .read(commentCreateProvider(widget.threadId).notifier)
                        .changeAsset(fileIndex, croppedFile.path);
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
