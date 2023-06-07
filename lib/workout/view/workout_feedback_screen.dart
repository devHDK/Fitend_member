import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/dialog_tools.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/schedule/model/post_workout_record_feedback_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutFeedbackScreen extends ConsumerStatefulWidget {
  static String get routeName => 'workoutFeedback';

  final int workoutScheduleId;

  const WorkoutFeedbackScreen({
    super.key,
    required this.workoutScheduleId,
  });

  @override
  ConsumerState<WorkoutFeedbackScreen> createState() =>
      _WorkoutFeedbackScreenState();
}

const TextStyle _titleStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w700,
);

class _WorkoutFeedbackScreenState extends ConsumerState<WorkoutFeedbackScreen> {
  FocusNode focusNode = FocusNode();
  final contentsController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  double _scrollOffset = 0.0;
  double keyboardHeight = 0;

  int strengthIndex = 0;
  List<int> issueIndexes = [];
  String contents = '';

  bool initKeyboardVisible = true;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          focusNode.requestFocus();
          addKeyboardHeightListener();
          print('scrollController.offset :  ${scrollController.offset}');
          print('keyboardHeight :  $keyboardHeight');
          scrollController.animateTo(
            _scrollOffset + 345,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );
        });
      } else {
        setState(() {
          focusNode.unfocus();
          removeKeyboardHeightListener();
        });
      }
    });

    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    focusNode.removeListener(() {});
    focusNode.dispose();
    scrollController.removeListener(() {});
    scrollController.dispose();
    contentsController.dispose();

    super.dispose();
  }

  void addKeyboardHeightListener() {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final newKeyboardHeight = viewInsets.bottom;
    print('newKeyboardHeight : $newKeyboardHeight');
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
    final size = MediaQuery.of(context).size;
    final repository = ref.read(workoutScheduleRepositoryProvider);
    final AsyncValue<Box> workoutFeedbackBox =
        ref.watch(hiveWorkoutFeedbackProvider);

    final baseBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: DARK_GRAY_COLOR,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: AppBar(
          backgroundColor: BACKGROUND_COLOR,
          title: const Text(
            '운동 평가',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: focusNode.hasFocus ? 345 : 0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _renderStrengthFeedBack(),
                      const SizedBox(
                        height: 24,
                      ),
                      _renderIssueFeedback(size),
                      const SizedBox(
                        height: 24,
                      ),
                      _renderContentFeedback(baseBorder, size),
                      const SizedBox(
                        height: 40,
                      ),
                      TextButton(
                        onPressed: strengthIndex == 0
                            ? () {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => DialogTools.errorDialog(
                                    message: '운동 강도를 평가해 주세요!',
                                    confirmText: '확인',
                                    confirmOnTap: () {
                                      context.pop();
                                    },
                                  ),
                                );
                              }
                            : () async {
                                try {
                                  await repository.postWorkoutRecordsFeedback(
                                    id: widget.workoutScheduleId,
                                    body: PostWorkoutRecordFeedbackModel(
                                      strengthIndex: strengthIndex,
                                      issueIndexes: issueIndexes,
                                      contents: contentsController.text.isEmpty
                                          ? null
                                          : contentsController.text,
                                    ),
                                  );

                                  workoutFeedbackBox.whenData(
                                    (value) {
                                      final record =
                                          value.get(widget.workoutScheduleId);

                                      if (record != null &&
                                          record
                                              is WorkoutFeedbackRecordModel) {
                                        value.put(
                                          widget.workoutScheduleId,
                                          record.copyWith(
                                            strengthIndex: strengthIndex,
                                            issueIndexes: issueIndexes,
                                            contents:
                                                contentsController.text.isEmpty
                                                    ? null
                                                    : contentsController.text,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                } on DioError catch (e) {
                                  print(e.message);

                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) =>
                                        DialogTools.errorDialog(
                                      message: e.error != null
                                          ? e.error.toString()
                                          : '',
                                      confirmText: '확인',
                                      confirmOnTap: () => context.pop(),
                                    ),
                                  );
                                }
                              },
                        child: Container(
                          width: size.width,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: POINT_COLOR,
                          ),
                          child: const Center(
                            child: Text(
                              '평가 저장하기',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _renderContentFeedback(OutlineInputBorder baseBorder, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '코치님께 전하고 싶은 내용을 적어주세요 📤',
          style: _titleStyle,
        ),
        const SizedBox(
          height: 12,
        ),
        TextFormField(
          maxLines: 8,
          style: const TextStyle(color: Colors.white),
          controller: contentsController,
          cursorColor: POINT_COLOR,
          focusNode: focusNode,
          onTapOutside: (event) {
            focusNode.unfocus();
          },
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            focusColor: POINT_COLOR,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 11,
            ),
            filled: true,
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: baseBorder.copyWith(
              borderSide: baseBorder.borderSide.copyWith(
                color: POINT_COLOR,
              ),
            ),
            labelText: focusNode.hasFocus || contentsController.text.isNotEmpty
                ? '자유롭게 입력해주세요'
                : '운동관련 궁금증, 요청사항 등을 형식에 관계없이\n자유롭게 입력해주세요 :)',
            labelStyle: TextStyle(
              color: focusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Column _renderIssueFeedback(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '특이사항이 있다면 알려주세요 🙏',
          style: _titleStyle,
        ),
        const SizedBox(
          height: 12,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (issueIndexes.contains(1)) {
                issueIndexes.remove(1);
              } else {
                issueIndexes.add(1);
              }
            });
          },
          child: _issueContainer(
            size,
            text: '운동 부위에 통증이 있어요',
            isSelected: issueIndexes.contains(1),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (issueIndexes.contains(2)) {
                issueIndexes.remove(2);
              } else {
                issueIndexes.add(2);
              }
            });
          },
          child: _issueContainer(
            size,
            text: '운동 자세를 잘 모르겠어요',
            isSelected: issueIndexes.contains(2),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (issueIndexes.contains(3)) {
                issueIndexes.remove(3);
              } else {
                issueIndexes.add(3);
              }
            });
          },
          child: _issueContainer(
            size,
            text: '운동 자극이 잘 안 느껴져요',
            isSelected: issueIndexes.contains(3),
          ),
        )
      ],
    );
  }

  Column _renderStrengthFeedBack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '운동의 강도는 어떠셨나요? 🔥',
          style: _titleStyle,
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  strengthIndex = 1;
                });
              },
              child: _strengthContainer(
                icon: '😁',
                text: '매우\n쉬움',
                isSelected: strengthIndex == 1,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  strengthIndex = 2;
                });
              },
              child: _strengthContainer(
                  icon: '😀', text: '쉬움', isSelected: strengthIndex == 2),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  strengthIndex = 3;
                });
              },
              child: _strengthContainer(
                  icon: '😊', text: '보통', isSelected: strengthIndex == 3),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  strengthIndex = 4;
                });
              },
              child: _strengthContainer(
                  icon: '😓', text: '힘듦', isSelected: strengthIndex == 4),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  strengthIndex = 5;
                });
              },
              child: _strengthContainer(
                  icon: '🥵', text: '매우\n힘듦', isSelected: strengthIndex == 5),
            ),
          ],
        )
      ],
    );
  }

  Container _strengthContainer({
    required String icon,
    required String text,
    required bool isSelected,
  }) {
    return Container(
      height: 101,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? POINT_COLOR : DARK_GRAY_COLOR,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.white : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 26,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 44,
              width: 25,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? POINT_COLOR : GRAY_COLOR,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _issueContainer(
    Size size, {
    required String text,
    required bool isSelected,
  }) {
    return Container(
      height: 42,
      width: size.width,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? POINT_COLOR : DARK_GRAY_COLOR,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.white : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? POINT_COLOR : GRAY_COLOR,
          ),
        ),
      ),
    );
  }
}
