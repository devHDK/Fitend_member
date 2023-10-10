import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/asset_edit_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ThreadCreateScreen extends ConsumerStatefulWidget {
  const ThreadCreateScreen({super.key});

  @override
  ConsumerState<ThreadCreateScreen> createState() => _ThreadCreateScreenState();
}

class _ThreadCreateScreenState extends ConsumerState<ThreadCreateScreen> {
  bool isLoading = false;

  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  final titleController = TextEditingController();
  final contentsController = TextEditingController();

  final baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.transparent,
      width: 1,
    ),
  );

  @override
  void initState() {
    super.initState();

    titleFocusNode.addListener(_titleFocusnodeListner);
    contentFocusNode.addListener(_contentFocusnodeListner);
  }

  @override
  void dispose() {
    titleFocusNode.removeListener(_titleFocusnodeListner);
    contentFocusNode.removeListener(_contentFocusnodeListner);
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    contentsController.dispose();

    super.dispose();
  }

  void _titleFocusnodeListner() {
    if (titleFocusNode.hasFocus) {
      setState(() {
        titleFocusNode.requestFocus();
      });
    } else {
      setState(() {
        titleFocusNode.unfocus();
      });
    }
  }

  void _contentFocusnodeListner() {
    if (contentFocusNode.hasFocus) {
      setState(() {
        contentFocusNode.requestFocus();
      });
    } else {
      setState(() {
        contentFocusNode.unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadCreateProvider);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); //뒤로가기
          },
          icon: const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Icon(Icons.close_sharp),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: TextButton(
                onPressed: () async {},
                child: Container(
                  width: 53,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: contentsController.text.isNotEmpty
                        ? POINT_COLOR
                        : POINT_COLOR.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Text(
                      '등록',
                      style: h6Headline.copyWith(
                        color: contentsController.text.isNotEmpty
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        height: 1,
                      ),
                    ),
                  ),
                )),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 40,
          child: Stack(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset('asset/img/icon_camera.svg'),
                  ),
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(threadProvider.notifier)
                          .pickImage(context)
                          .then((assets) async {
                        if (assets != null && assets.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });

                          for (var asset in assets) {
                            if (await asset.file != null) {
                              final file = await asset.file;

                              ref
                                  .read(threadCreateProvider.notifier)
                                  .addAssets(file!.path);
                            }
                          }

                          setState(() {
                            isLoading = false;
                          });
                        } else {
                          print('assets: $assets');
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset('asset/img/icon_picture.svg'),
                    ),
                  ),
                ],
              ),
              KeyboardVisibilityBuilder(
                builder: (p0, isKeyboardVisible) {
                  if (isKeyboardVisible) {
                    return Positioned(
                      right: 10,
                      top: 0,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          '완료',
                          style: h6Headline.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              maxLines: 1,
              style: const TextStyle(color: Colors.white),
              controller: titleController,
              cursorColor: POINT_COLOR,
              focusNode: titleFocusNode,
              onTapOutside: (event) {
                titleFocusNode.unfocus();
              },
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                focusColor: POINT_COLOR,
                border: baseBorder,
                disabledBorder: baseBorder,
                enabledBorder: baseBorder,
                focusedBorder: baseBorder,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                filled: true,
                labelText:
                    titleFocusNode.hasFocus || titleController.text.isNotEmpty
                        ? ''
                        : '제목을 추가하시겠어요?',
                labelStyle: s1SubTitle.copyWith(
                  color: titleFocusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
                ),
              ),
            ),
            TextFormField(
              maxLines: 20,
              style: const TextStyle(color: Colors.white),
              controller: contentsController,
              cursorColor: POINT_COLOR,
              focusNode: contentFocusNode,
              onTapOutside: (event) {
                contentFocusNode.unfocus();
              },
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                focusColor: POINT_COLOR,
                border: baseBorder,
                disabledBorder: baseBorder,
                enabledBorder: baseBorder,
                focusedBorder: baseBorder,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                filled: true,
                labelStyle: s1SubTitle.copyWith(
                  color: contentFocusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
                ),
                label: Text(
                  contentFocusNode.hasFocus ||
                          contentsController.text.isNotEmpty
                      ? ''
                      : '여기를 눌러 시작해주세요\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',
                  style: s1SubTitle.copyWith(
                    color: contentFocusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 140,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: POINT_COLOR,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final intPath = utf8.encode(state.assetsPaths![index]);
                        final path = Uint8List.fromList(intPath);
                        final file = File.fromRawPath(path);
                        final type = MediaUtils.getMediaType(file.path);
                        return Stack(
                          children: [
                            SizedBox(
                              child: Center(
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () => Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => AssetEditScreen(
                                        parentUpdate: () {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  child: type == MediaType.image
                                      ? PreviewImage(
                                          file: file,
                                        )
                                      : PreviewVideoThumbNail(file: file),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -13,
                              top: -13,
                              child: IconButton(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onPressed: () {
                                  setState(() {
                                    ref
                                        .read(threadCreateProvider.notifier)
                                        .removeAsset(index);
                                  });
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  color: LIGHT_GRAY_COLOR,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: state.assetsPaths!.length,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
