import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
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
  FocusNode titleFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();
  final titleController = TextEditingController();
  final contentsController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  double _scrollOffset = 0.0;
  double keyboardHeight = 0;

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

    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    titleFocusNode.removeListener(_titleFocusnodeListner);
    contentFocusNode.removeListener(_contentFocusnodeListner);
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    contentsController.dispose();

    super.dispose();
  }

  void _titleFocusnodeListner() {
    if (titleFocusNode.hasFocus) {
      setState(() {
        titleFocusNode.requestFocus();
        addKeyboardHeightListener();
        scrollController.animateTo(
          _scrollOffset + 325,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    } else {
      setState(() {
        titleFocusNode.unfocus();
        removeKeyboardHeightListener();
      });
    }
  }

  void _contentFocusnodeListner() {
    if (contentFocusNode.hasFocus) {
      setState(() {
        contentFocusNode.requestFocus();
        addKeyboardHeightListener();
        scrollController.animateTo(
          _scrollOffset + 325,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    } else {
      setState(() {
        contentFocusNode.unfocus();
        removeKeyboardHeightListener();
      });
    }
  }

  void addKeyboardHeightListener() {
    final viewInsets = MediaQuery.paddingOf(context);
    final newKeyboardHeight = viewInsets.bottom;
    if (newKeyboardHeight > 0) {
      setState(() => keyboardHeight = newKeyboardHeight);
    } else {
      removeKeyboardHeightListener();
    }
  }

  void removeKeyboardHeightListener() {
    setState(() => keyboardHeight = 0);
  }

  void _scrollListener() {
    setState(() {
      _scrollOffset = scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(threadProvider);

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
                      final assets = await ref
                          .read(threadProvider.notifier)
                          .pickImage(context);

                      if (assets != null && assets.isNotEmpty) {
                        print(assets);
                      }
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
              maxLines: 30,
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
                      : '여기를 눌러 시작해주세요\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',
                  style: s1SubTitle.copyWith(
                    color: contentFocusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
