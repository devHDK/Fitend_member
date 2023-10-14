import 'dart:convert';
import 'dart:io';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/asset_edit_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ThreadCreateScreen extends ConsumerStatefulWidget {
  const ThreadCreateScreen({
    super.key,
    required this.trainerId,
  });

  final int trainerId;

  @override
  ConsumerState<ThreadCreateScreen> createState() => _ThreadCreateScreenState();
}

class _ThreadCreateScreenState extends ConsumerState<ThreadCreateScreen> {
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

    if (state.isUploading && state.doneCount != state.totalCount) {
      return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        color: POINT_COLOR,
                        backgroundColor: Colors.transparent,
                        value: state.doneCount / state.totalCount,
                        strokeWidth: 9,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: Text(
                          '${(state.doneCount / state.totalCount * 100).toInt()}%',
                          style: h4Headline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'UPLOADING',
                  style: h4Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      );
    }

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
              onPressed: state.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(threadCreateProvider.notifier)
                          .createThread(widget.trainerId)
                          .then((value) => context.pop());
                    },
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
                  child: state.isLoading || state.isUploading
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '등록',
                          style: h6Headline.copyWith(
                            color: contentsController.text.isNotEmpty
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            height: 1,
                          ),
                        ),
                ),
              ),
            ),
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
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(threadCreateProvider.notifier)
                          .pickCamera(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset('asset/img/icon_camera.svg'),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(threadCreateProvider.notifier)
                          .pickImage(context)
                          .then((assets) async {
                        if (assets != null && assets.isNotEmpty) {
                          ref
                              .read(threadCreateProvider.notifier)
                              .updateIsLoading(true);

                          for (var asset in assets) {
                            if (await asset.file != null) {
                              final file = await asset.file;

                              ref
                                  .read(threadCreateProvider.notifier)
                                  .addAssets(file!.path);

                              debugPrint('file.path : ${file.path}');
                            }
                          }

                          ref
                              .read(threadCreateProvider.notifier)
                              .updateIsLoading(false);
                        } else {
                          debugPrint('assets: $assets');
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
            _titleTextFormfield(),
            _contentTextFormField(),
            SizedBox(
              height: 140,
              child: state.isLoading
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
                                      builder: (context) {
                                        return AssetEditScreen(
                                          pageIndex: index,
                                        );
                                      },
                                    ),
                                  ),
                                  child: type == MediaType.image
                                      ? Hero(
                                          tag: file.path,
                                          child: PreviewImage(
                                            file: file,
                                          ),
                                        )
                                      : Hero(
                                          tag: state.assetsPaths![index],
                                          child: PreviewVideoThumbNail(
                                            file: file,
                                          ),
                                        ),
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
                                  ref
                                      .read(threadCreateProvider.notifier)
                                      .removeAsset(index);
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
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _contentTextFormField() {
    return TextFormField(
      onChanged: (value) {
        ref.read(threadCreateProvider.notifier).updateContent(value);
      },
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
          contentFocusNode.hasFocus || contentsController.text.isNotEmpty
              ? ''
              : '여기를 눌러 시작해주세요\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',
          style: s1SubTitle.copyWith(
            color: GRAY_COLOR,
          ),
        ),
      ),
    );
  }

  TextFormField _titleTextFormfield() {
    return TextFormField(
      onChanged: (value) {
        ref.read(threadCreateProvider.notifier).updateTitle(value);
      },
      maxLines: 1,
      style: const TextStyle(color: Colors.white),
      controller: titleController,
      cursorColor: POINT_COLOR,
      focusNode: titleFocusNode,
      onTapOutside: (event) {
        titleFocusNode.unfocus();
      },
      keyboardType: TextInputType.text,
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
        labelText: titleFocusNode.hasFocus || titleController.text.isNotEmpty
            ? ''
            : '제목을 추가하시겠어요?',
        labelStyle: s1SubTitle.copyWith(
          color: titleFocusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
        ),
      ),
    );
  }
}
