import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/comment_cell.dart';
import 'package:fitend_member/thread/component/link_preview.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/component/thread_detail.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_create_model.dart';
import 'package:fitend_member/thread/model/exception/exceptios.dart';
import 'package:fitend_member/thread/model/threads/thread_comment_edit_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/comment_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/utils/thread_push_update_utils.dart';
import 'package:fitend_member/thread/view/comment_asset_edit_screen.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ThreadDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'threadDetail';

  const ThreadDetailScreen({
    super.key,
    required this.threadId,
  });

  final int threadId;

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen>
    with WidgetsBindingObserver, RouteAware {
  FocusNode commentFocusNode = FocusNode();
  final commentController = TextEditingController();
  int maxLine = 1;

  int edittingCommentId = -1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    commentFocusNode.addListener(_commentFocusnodeListner);
  }

  @override
  void dispose() {
    commentFocusNode.removeListener(_commentFocusnodeListner);
    commentFocusNode.dispose();
    commentController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _commentFocusnodeListner() {
    if (mounted) {
      if (commentFocusNode.hasFocus) {
        setState(() {
          commentFocusNode.requestFocus();
        });
      } else {
        setState(() {
          commentFocusNode.unfocus();
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await ThreadUpdateUtils.checkThreadNeedUpdate(ref);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void didPush() async {
    await ThreadUpdateUtils.checkThreadNeedUpdate(ref);
    super.didPush();
  }

  @override
  void didPop() async {
    await ThreadUpdateUtils.checkThreadNeedUpdate(ref);
    super.didPop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadDetailProvider(widget.threadId));
    final commentState = ref.watch(commentCreateProvider(widget.threadId));

    if (state is ThreadModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (state is ThreadModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: DialogWidgets.oneButtonDialog(
          message: state.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final model = state as ThreadModel;

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back)),
        ),
        centerTitle: true,
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(model.createdAt))} ${weekday[DateTime.parse(model.createdAt).weekday - 1]}요일',
          style: h4Headline,
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            backgroundColor: Pallete.background,
            color: Pallete.point,
            onRefresh: () async {
              await ref
                  .read(threadDetailProvider(widget.threadId).notifier)
                  .getThreadDetail(
                    threadId: widget.threadId,
                  );
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ThreadDetail(
                    dateTime: DateTime.parse(model.createdAt).toUtc().toLocal(),
                    threadId: widget.threadId,
                  ),
                ),
                if (model.comments != null && model.comments!.isNotEmpty)
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      if (index != 0 && index == model.comments!.length) {
                        return const SizedBox(
                          height: 300,
                        );
                      }

                      final commentModel = model.comments![index];

                      return Stack(
                        children: [
                          CommentCell(
                            threadId: widget.threadId,
                            commentId: commentModel.id,
                            content: commentModel.content,
                            dateTime: DateTime.parse(commentModel.createdAt)
                                .toUtc()
                                .toLocal(),
                            user: commentModel.user,
                            trainer: commentModel.trainer,
                            emojis: commentModel.emojis!,
                            gallery: commentModel.gallery,
                            isEditting: commentModel.id == edittingCommentId,
                          ),
                          if (commentModel.user != null &&
                              model.user.id == commentModel.user!.id &&
                              edittingCommentId == -1 &&
                              !commentState.isUploading)
                            Positioned(
                              top: -5,
                              right: 18,
                              child: InkWell(
                                onTap: () => DialogWidgets.editBottomModal(
                                  context,
                                  delete: () async {
                                    context.pop();

                                    await ref
                                        .read(threadDetailProvider(
                                                widget.threadId)
                                            .notifier)
                                        .deleteComment(commentModel.id);
                                  },
                                  edit: () async {
                                    context.pop();

                                    ref
                                        .read(commentCreateProvider(
                                                commentModel.threadId)
                                            .notifier)
                                        .updateFromEditModel(
                                            ThreadCommentEditModel(
                                                threadId: commentModel.threadId,
                                                content: commentModel.content,
                                                gallery: commentModel.gallery));
                                    if (mounted) {
                                      setState(() {
                                        commentController.text =
                                            commentModel.content;

                                        edittingCommentId = commentModel.id;
                                      });
                                    }
                                  },
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: SvgPicture.asset(SVGConstants.edit),
                                ),
                              ),
                            )
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: model.comments!.length + 1,
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Text(
                            '아직 댓글이 없어요 :)',
                            style: s1SubTitle.copyWith(
                              color: Pallete.gray,
                              height: 1,
                            ),
                          ),
                          const SizedBox(
                            height: 200,
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          _bottomInputBox(commentState, model, context),
        ],
      ),
    );
  }

  Positioned _bottomInputBox(
    ThreadCommentCreateTempModel commentState,
    ThreadModel model,
    BuildContext context,
  ) {
    List<String> commentCreateLinkUrl = [];
    String commentProcessedText = commentController.text.replaceAll('\n', ' ');

    commentProcessedText.split(' ').forEach(
      (word) {
        if (urlRegExp.hasMatch(word)) {
          commentCreateLinkUrl.add(word);
        }
      },
    );

    final tempList = [
      ...commentState.assetsPaths,
      ...commentCreateLinkUrl,
    ];

    return Positioned(
      child: SlidingUpPanel(
        minHeight:
            tempList.isNotEmpty ? 220 + maxLine * 10 : 120 + maxLine * 10,
        maxHeight:
            tempList.isNotEmpty ? 220 + maxLine * 10 : 120 + maxLine * 10,
        color: Pallete.darkGray,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        panel: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircleProfileImage(
                      image: CachedNetworkImage(
                        imageUrl: model.user.gender == 'male'
                            ? URLConstants.maleProfileUrl
                            : URLConstants.femaleProfileUrl,
                      ),
                      borderRadius: 17,
                    ),
                  ),
                  SizedBox(
                    width: 100.w - 56 - 34,
                    child: commentState.isUploading
                        ? null
                        : _commentTextFormField(),
                  ),
                ],
              ),
              if (tempList.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: commentState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Pallete.point,
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) => const SizedBox(
                            width: 10,
                          ),
                          itemBuilder: (context, index) {
                            if (index >= commentState.assetsPaths.length) {
                              return LinkPreview(
                                url: tempList[index],
                                width: 100,
                                height: 80,
                              );
                            }

                            final intPath =
                                utf8.encode(commentState.assetsPaths[index]);
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
                                      onTap: () => commentState.isUploading
                                          ? null
                                          : Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                builder: (context) {
                                                  return CommentAssetEditScreen(
                                                    pageIndex: index,
                                                    threadId: widget.threadId,
                                                  );
                                                },
                                              ),
                                            ),
                                      child: type == MediaType.image
                                          ? Hero(
                                              tag: file.path,
                                              child: PreviewImage(
                                                file: file,
                                                width: 100,
                                              ),
                                            )
                                          : Hero(
                                              tag: commentState
                                                  .assetsPaths[index],
                                              child: PreviewVideoThumbNail(
                                                file: file,
                                                width: 100,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                if (!commentState.isUploading)
                                  Positioned(
                                    right: -13,
                                    top: -13,
                                    child: IconButton(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onPressed: () {
                                        ref
                                            .read(commentCreateProvider(
                                                    widget.threadId)
                                                .notifier)
                                            .removeAsset(index);

                                        if (edittingCommentId != -1) {
                                          ref
                                              .read(commentCreateProvider(
                                                      widget.threadId)
                                                  .notifier)
                                              .updateFileCheck('remove', index);

                                          ref
                                              .read(commentCreateProvider(
                                                      commentState.threadId)
                                                  .notifier)
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
              commentState.isUploading && commentState.totalCount > 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              value: (commentState.doneCount) /
                                  commentState.totalCount,
                              backgroundColor: Pallete.gray,
                            ),
                          )
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            await ref
                                .read(commentCreateProvider(widget.threadId)
                                    .notifier)
                                .pickCamera(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, right: 10),
                            child: SvgPicture.asset(SVGConstants.camera),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (commentState.assetsPaths.length < 10) {
                              await ref
                                  .read(commentCreateProvider(widget.threadId)
                                      .notifier)
                                  .pickImage(context,
                                      10 - commentState.assetsPaths.length)
                                  .then(
                                (assets) async {
                                  if (assets != null && assets.isNotEmpty) {
                                    ref
                                        .read(commentCreateProvider(
                                                widget.threadId)
                                            .notifier)
                                        .updateIsLoading(true);

                                    for (var asset in assets) {
                                      if (await asset.file != null) {
                                        final file = await asset.file;

                                        ref
                                            .read(commentCreateProvider(
                                                    widget.threadId)
                                                .notifier)
                                            .addAssets(file!.path);

                                        if (edittingCommentId != -1) {
                                          ref
                                              .read(commentCreateProvider(
                                                      widget.threadId)
                                                  .notifier)
                                              .updateFileCheck('add', 0);
                                        }

                                        debugPrint('file.path : ${file.path}');
                                      }
                                    }

                                    ref
                                        .read(commentCreateProvider(
                                                widget.threadId)
                                            .notifier)
                                        .updateIsLoading(false);
                                  } else {
                                    debugPrint('assets: $assets');
                                  }
                                },
                              );
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
                        const Spacer(),
                        if (edittingCommentId == -1)
                          InkWell(
                            onTap: commentState.isLoading ||
                                    commentController.text.isEmpty
                                ? null
                                : () async {
                                    try {
                                      await ref
                                          .read(commentCreateProvider(
                                                  widget.threadId)
                                              .notifier)
                                          .createComment(
                                              widget.threadId, model.user)
                                          .then((value) {
                                        if (mounted) {
                                          setState(() {
                                            commentController.text = '';
                                          });
                                        }
                                      });
                                    } catch (e) {
                                      if (e is UploadException) {
                                        if (e.message ==
                                            'oversize_file_include_error') {
                                          DialogWidgets.showToast(
                                              content:
                                                  '400MB가 넘는 사진 또는 영상은 첨부할수 없습니다.');
                                        } else {
                                          DialogWidgets.showToast(
                                              content: '업로드 중 문제가 발생하였습니다.');
                                        }
                                      }
                                    }
                                  },
                            child: Container(
                              width: 53,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: commentController.text.isNotEmpty
                                    ? Pallete.point
                                    : Pallete.point.withOpacity(0.5),
                              ),
                              child: Center(
                                child: commentState.isLoading ||
                                        commentState.isUploading
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
                                          color: commentController
                                                  .text.isNotEmpty
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                          height: 1,
                                        ),
                                      ),
                              ),
                            ),
                          )
                        else
                          commentState.isLoading || commentState.isUploading
                              ? Container(
                                  width: 53,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Pallete.point.withOpacity(0.5),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(
                                                commentCreateProvider(model.id)
                                                    .notifier)
                                            .init();

                                        commentController.text = '';
                                        if (mounted) {
                                          setState(() {
                                            edittingCommentId = -1;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 45,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Pallete.point, width: 1),
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Pallete.point),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        try {
                                          await ref
                                              .read(commentCreateProvider(
                                                      commentState.threadId)
                                                  .notifier)
                                              .updateComment(
                                                edittingCommentId,
                                                commentState.gallery,
                                              )
                                              .then((value) {
                                            ref
                                                .read(commentCreateProvider(
                                                        commentState.threadId)
                                                    .notifier)
                                                .init();
                                            if (mounted) {
                                              setState(() {
                                                edittingCommentId = -1;
                                                commentController.text = '';
                                              });
                                            }
                                          });
                                        } catch (e) {
                                          if (e is UploadException) {
                                            if (e.message ==
                                                'oversize_file_include_error') {
                                              DialogWidgets.showToast(
                                                  content:
                                                      '400MB가 넘는 사진 또는 영상은 첨부할수 없습니다.');
                                            } else {
                                              DialogWidgets.showToast(
                                                  content:
                                                      '업로드 중 문제가 발생하였습니다.');
                                            }
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: 45,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Pallete.point,
                                        ),
                                        child: SvgPicture.asset(
                                          SVGConstants.checkSave,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _commentTextFormField() {
    const baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 1,
      ),
    );

    return TextFormField(
      autocorrect: false,
      onChanged: (value) {
        ref
            .read(commentCreateProvider(widget.threadId).notifier)
            .updateContent(value);
        if (mounted) {
          setState(() {
            maxLine = '\n'.allMatches(value).length + 1;

            if (maxLine > 3) {
              maxLine = 3;
            }
          });
        }
      },
      maxLines: maxLine > 1 ? maxLine : null,
      style: const TextStyle(color: Colors.white),
      controller: commentController,
      cursorColor: Pallete.point,
      focusNode: commentFocusNode,
      onTapOutside: (event) {
        commentFocusNode.unfocus();
      },
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        focusColor: Pallete.point,
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
          color: commentFocusNode.hasFocus ? Pallete.point : Pallete.gray,
        ),
        label: Text(
          commentFocusNode.hasFocus || commentController.text.isNotEmpty
              ? ''
              : '댓글을 입력해주세요',
          style: s1SubTitle.copyWith(
            color: Pallete.gray,
          ),
        ),
      ),
    );
  }
}
