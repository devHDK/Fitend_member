import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AssetEditScreen extends ConsumerStatefulWidget {
  const AssetEditScreen({
    super.key,
    this.parentUpdate,
  });
  final Function? parentUpdate;

  @override
  ConsumerState<AssetEditScreen> createState() => _AssetEditScreenState();
}

class _AssetEditScreenState extends ConsumerState<AssetEditScreen> {
  int fileIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadCreateProvider);

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
            height: 70.h,
            child: PageView.builder(
              itemBuilder: (context, index) {
                final intPath = utf8.encode(state.assetsPaths![index]);
                final path = Uint8List.fromList(intPath);
                final file = File.fromRawPath(path);

                return Image.file(
                  file,
                  fit: BoxFit.contain,
                );
              },
              itemCount: state.assetsPaths!.length,
              onPageChanged: (value) {
                setState(() {
                  fileIndex = value;
                });
              },
            ),
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
                          title: 'Cropper',
                          doneButtonTitle: '저장',
                          cancelButtonTitle: '취소',
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
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
