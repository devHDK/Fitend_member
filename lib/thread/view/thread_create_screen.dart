import 'dart:convert';
import 'dart:io';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/tip_bubble.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/link_preview.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/exception/exceptios.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/model/threads/thread_edit_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/thread_asset_edit_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ThreadCreateScreen extends ConsumerStatefulWidget {
  const ThreadCreateScreen({
    super.key,
    required this.trainer,
    required this.user,
    this.threadEditModel,
    this.title,
  });

  final ThreadTrainer trainer;
  final ThreadUser user;
  final ThreadEditModel? threadEditModel;
  final String? title; //운동 thread 작성시

  @override
  ConsumerState<ThreadCreateScreen> createState() => _ThreadCreateScreenState();
}

class _ThreadCreateScreenState extends ConsumerState<ThreadCreateScreen> {
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  TextEditingController? titleController;
  TextEditingController? contentsController;

  final baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.transparent,
      width: 1,
    ),
  );

  late final ThreadCreateTempModel model;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleFocusNode.addListener(_titleFocusnodeListner);
    contentFocusNode.addListener(_contentFocusnodeListner);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (widget.threadEditModel != null) {
        titleController =
            TextEditingController(text: widget.threadEditModel!.title);
        contentsController =
            TextEditingController(text: widget.threadEditModel!.content);
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        ref
            .read(threadCreateProvider.notifier)
            .updateFromEditModel(widget.threadEditModel!)
            .then((value) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }); //edit 내용으로 업데이트
      } else if (widget.title != null) {
        await ref.read(threadCreateProvider.notifier).init();

        titleController = TextEditingController(text: widget.title);
        contentsController = TextEditingController();

        ref.read(threadCreateProvider.notifier).updateTitle(widget.title);

        if (mounted) {
          setState(() {});
        }
      } else {
        model = ref.read(threadCreateProvider);

        titleController = TextEditingController(text: model.title);
        contentsController = TextEditingController(text: model.content);

        ref.read(threadCreateProvider.notifier).updateFromCache(model);
      }
    });
  }

  @override
  void dispose() {
    titleFocusNode.removeListener(_titleFocusnodeListner);
    contentFocusNode.removeListener(_contentFocusnodeListner);

    titleFocusNode.dispose();
    contentFocusNode.dispose();

    titleController!.dispose();
    contentsController!.dispose();

    super.dispose();
  }

  void _titleFocusnodeListner() {
    if (mounted) {
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
  }

  void _contentFocusnodeListner() {
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadCreateProvider);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    List<String> linkUrls = [];
    String processedText = '';

    if (contentsController != null) {
      processedText = contentsController!.text.replaceAll('\n', ' ');
    }

    processedText.split(' ').forEach(
      (word) {
        if (urlRegExp.hasMatch(word)) {
          linkUrls.add(word);
        }
      },
    );

    final tempList = [
      ...state.assetsPaths!,
      ...linkUrls,
    ];

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop(widget.threadEditModel != null ? true : null);
          },
          icon: const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Icon(Icons.close_sharp),
          ),
        ),
        bottom: state.isUploading && state.totalCount > 0
            ? PreferredSize(
                preferredSize: Size(100.w, 30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      Text(
                        'UPLOADING',
                        style: h6Headline.copyWith(
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      LoadingAnimationWidget.dotsTriangle(
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          color: Pallete.point,
                          value: (state.doneCount) / state.totalCount,
                          backgroundColor: Pallete.gray,
                        ),
                      )
                    ],
                  ),
                ),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: TextButton(
              onPressed: state.isLoading || state.content.isEmpty
                  ? null
                  : widget.threadEditModel == null
                      ? () async {
                          try {
                            ref
                                .read(threadCreateProvider.notifier)
                                .createThread(
                                  user: widget.user,
                                  trainer: widget.trainer,
                                );

                            context.pop();
                          } catch (e) {
                            if (e is UploadException) {
                              if (e.message == 'oversize_file_include_error') {
                                DialogWidgets.showToast(
                                    content: '400MB가 넘는 사진 또는 영상은 첨부할수 없습니다.');
                              } else {
                                DialogWidgets.showToast(
                                    content: '업로드 중 문제가 발생하였습니다.');
                              }
                            } else {
                              DialogWidgets.showToast(
                                  content: '업로드 중 문제가 발생하였습니다.');
                            }
                          }
                        }
                      : () async {
                          try {
                            await ref
                                .read(threadCreateProvider.notifier)
                                .updateThread(
                                  widget.user,
                                  widget.trainer,
                                  widget.threadEditModel!.threadId,
                                  widget.threadEditModel!.gallery,
                                )
                                .then((value) {
                              if (value != null) {
                                ref
                                    .read(threadProvider.notifier)
                                    .updateThreadWithModel(
                                        widget.threadEditModel!.threadId,
                                        value);

                                ref
                                    .read(threadDetailProvider(
                                            widget.threadEditModel!.threadId)
                                        .notifier)
                                    .updateThreadWithModel(
                                        widget.threadEditModel!.threadId,
                                        value);
                              }

                              context.pop();
                            });
                          } catch (e) {
                            if (e is UploadException) {
                              if (e.message == 'oversize_file_include_error') {
                                DialogWidgets.showToast(
                                    content: '400MB가 넘는 사진 또는 영상은 첨부할수 없습니다.');
                              } else {
                                DialogWidgets.showToast(
                                    content: '업로드 중 문제가 발생하였습니다.');
                              }
                            } else {
                              DialogWidgets.showToast(
                                  content: '업로드 중 문제가 발생하였습니다.');
                            }
                          }
                        },
              child: Container(
                width: 53,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: contentsController != null &&
                          contentsController!.text.isNotEmpty
                      ? Pallete.point
                      : Pallete.point.withOpacity(0.5),
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
                          widget.threadEditModel != null ? '수정' : '등록',
                          style: h6Headline.copyWith(
                            color: contentsController != null &&
                                    contentsController!.text.isNotEmpty
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
      floatingActionButton: state.isUploading || state.isLoading
          ? null
          : Padding(
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
                            child: SvgPicture.asset(SVGConstants.camera),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (state.assetsPaths!.length < 10) {
                              await ref
                                  .read(threadCreateProvider.notifier)
                                  .pickImage(
                                      context, 10 - state.assetsPaths!.length)
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

                                      if (widget.threadEditModel != null) {
                                        ref
                                            .read(threadCreateProvider.notifier)
                                            .updateFileCheck('add', 0);
                                      }

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
                            } else {
                              DialogWidgets.showToast(
                                  content: '사진 또는 영상은 10개까지만 첨부할수있습니다!');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(SVGConstants.picture),
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
            _titleTextFormfield(state),
            _contentTextFormField(state),
            SizedBox(
              height: 180,
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Pallete.point,
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        width: 10,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index >= state.assetsPaths!.length) {
                          return Row(
                            children: [
                              LinkPreview(
                                url: tempList[index],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          );
                        }

                        final intPath = utf8.encode(state.assetsPaths![index]);
                        final path = Uint8List.fromList(intPath);
                        final file = File.fromRawPath(path);
                        final type = MediaUtils.getMediaType(file.path);

                        return Stack(
                          children: [
                            if (index == 0 && state.isFirstRun)
                              Positioned(
                                left: 10,
                                top: -5,
                                child: TipBubble(
                                  text: '눌러서 편집하세요!',
                                  textStyle: s3SubTitle.copyWith(
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                  bubbleColor: Pallete.point,
                                  bubblePosition: BubblePosition.bottomLeft,
                                  distance: 48,
                                ),
                              ),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ),
                                SizedBox(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: state.isUploading
                                        ? null
                                        : () {
                                            if (mounted && state.isFirstRun) {
                                              ref
                                                  .read(threadCreateProvider
                                                      .notifier)
                                                  .putIsGuide(
                                                      isFirstRun: false);
                                            }

                                            Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                builder: (context) {
                                                  return ThreadAssetEditScreen(
                                                    pageIndex: index,
                                                    isThreadEdit:
                                                        widget.threadEditModel !=
                                                                null
                                                            ? true
                                                            : false,
                                                  );
                                                },
                                              ),
                                            );
                                          },
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
                              ],
                            ),
                            if (!state.isUploading)
                              Positioned(
                                right: -13,
                                top: 15,
                                child: IconButton(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onPressed: () {
                                    ref
                                        .read(threadCreateProvider.notifier)
                                        .removeAsset(index);

                                    if (widget.threadEditModel != null) {
                                      ref
                                          .read(threadCreateProvider.notifier)
                                          .updateFileCheck('remove', index);

                                      ref
                                          .read(threadCreateProvider.notifier)
                                          .removeAssetFromGallery(index);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Pallete.lightGray,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      itemCount: tempList.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _contentTextFormField(ThreadCreateTempModel state) {
    return TextFormField(
      autocorrect: false,
      onChanged: (value) {
        if (mounted) {
          ref.read(threadCreateProvider.notifier).updateContent(value);
          setState(() {});
        }
      },
      maxLines: 20,
      style: const TextStyle(color: Colors.white),
      controller: contentsController,
      cursorColor: Pallete.point,
      focusNode: contentFocusNode,
      onTapOutside: (event) {
        contentFocusNode.unfocus();
      },
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        focusColor: Pallete.point,
        border: baseBorder,
        disabledBorder: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 11,
        ),
        filled: true,
        labelStyle: s1SubTitle.copyWith(
          color: contentFocusNode.hasFocus ? Pallete.point : Pallete.gray,
        ),
        label: Text(
          contentFocusNode.hasFocus ||
                  (contentsController != null &&
                      contentsController!.text.isNotEmpty)
              ? ''
              : '여기를 눌러 시작해주세요\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',
          style: s1SubTitle.copyWith(
            color: Pallete.gray,
          ),
        ),
      ),
    );
  }

  TextFormField _titleTextFormfield(ThreadCreateTempModel state) {
    return TextFormField(
      autocorrect: false,
      onChanged: (value) {
        if (mounted) {
          ref.read(threadCreateProvider.notifier).updateTitle(value);
          setState(() {});
        }
      },
      maxLines: 1,
      style: const TextStyle(color: Colors.white),
      controller: titleController,
      cursorColor: Pallete.point,
      focusNode: titleFocusNode,
      onTapOutside: (event) {
        titleFocusNode.unfocus();
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        focusColor: Pallete.point,
        border: baseBorder,
        disabledBorder: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 11,
        ),
        filled: true,
        labelText: titleFocusNode.hasFocus ||
                (titleController != null && titleController!.text.isNotEmpty)
            ? ''
            : '제목을 추가하시겠어요?',
        labelStyle: s1SubTitle.copyWith(
          color: titleFocusNode.hasFocus ? Pallete.point : Pallete.gray,
        ),
      ),
    );
  }
}
