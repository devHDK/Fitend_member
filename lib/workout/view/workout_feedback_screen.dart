import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/post_workout_record_feedback_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/provider/schedule_provider.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/schedule/view/schedule_result_screen.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutFeedbackScreen extends ConsumerStatefulWidget {
  static String get routeName => 'workoutFeedback';

  final int workoutScheduleId;
  final List<Exercise>? exercises;
  final String startdate;

  const WorkoutFeedbackScreen({
    super.key,
    required this.workoutScheduleId,
    this.exercises,
    required this.startdate,
  });

  @override
  ConsumerState<WorkoutFeedbackScreen> createState() =>
      _WorkoutFeedbackScreenState();
}

final TextStyle _titleStyle = h5Headline.copyWith(
  color: Colors.white,
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
  bool buttonEnable = true;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(_focusnodeListner);

    scrollController.addListener(_scrollListener);
  }

  void _focusnodeListner() {
    if (focusNode.hasFocus) {
      setState(() {
        focusNode.requestFocus();
        addKeyboardHeightListener();
        scrollController.animateTo(
          _scrollOffset + 325,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    } else {
      setState(() {
        focusNode.unfocus();
        removeKeyboardHeightListener();
      });
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_focusnodeListner);
    focusNode.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    contentsController.dispose();

    super.dispose();
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
    final size = Size(100.w, 100.h);
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
          title: Text(
            '운동 평가',
            style: h4Headline,
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: focusNode.hasFocus ? 325 : 0,
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
                                  builder: (context) =>
                                      DialogWidgets.errorDialog(
                                    message: '운동 강도를 평가해 주세요!',
                                    confirmText: '확인',
                                    confirmOnTap: () {
                                      context.pop();
                                    },
                                  ),
                                );
                              }
                            : buttonEnable
                                ? () async {
                                    try {
                                      setState(() {
                                        buttonEnable = false;
                                      });

                                      await repository
                                          .postWorkoutRecordsFeedback(
                                        id: widget.workoutScheduleId,
                                        body: PostWorkoutRecordFeedbackModel(
                                          strengthIndex: strengthIndex,
                                          issueIndexes: issueIndexes,
                                          contents:
                                              contentsController.text.isEmpty
                                                  ? null
                                                  : contentsController.text,
                                        ),
                                      )
                                          .then(
                                        (value) {
                                          workoutFeedbackBox.whenData(
                                            (_) {
                                              final record = _.get(
                                                  widget.workoutScheduleId);

                                              if (record != null &&
                                                  record
                                                      is WorkoutFeedbackRecordModel) {
                                                _.put(
                                                  widget.workoutScheduleId,
                                                  record.copyWith(
                                                    strengthIndex:
                                                        strengthIndex,
                                                    issueIndexes: issueIndexes,
                                                    contents: contentsController
                                                            .text.isEmpty
                                                        ? null
                                                        : contentsController
                                                            .text,
                                                  ),
                                                );
                                              }
                                            },
                                          );

                                          ref
                                              .read(scheduleProvider.notifier)
                                              .updateScheduleState(
                                                workoutScheduleId:
                                                    widget.workoutScheduleId,
                                                startDate: DateTime.parse(
                                                    widget.startdate),
                                              );
                                          // 스케줄 상태 업데이트

                                          ref
                                              .read(workoutProvider(
                                                      widget.workoutScheduleId)
                                                  .notifier)
                                              .updateWorkoutStateIsComplete();
                                          //워크아웃 상태 업데이트

                                          // context.pop();

                                          context.goNamed(
                                            ScheduleResultScreen.routeName,
                                            pathParameters: {
                                              'id': widget.workoutScheduleId
                                                  .toString(),
                                            },
                                            // extra: widget.exercises,
                                          );
                                          // Navigator.of(context).pushReplacement(
                                          //   CupertinoPageRoute(
                                          //     builder: (context) =>
                                          //         ScheduleResultScreen(
                                          //       workoutScheduleId:
                                          //           widget.workoutScheduleId,
                                          //       exercises: widget.exercises,
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                      );
                                    } on DioException catch (e) {
                                      setState(() {
                                        buttonEnable = true;
                                      });

                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) =>
                                            DialogWidgets.errorDialog(
                                          message:
                                              e.response!.statusCode.toString(),
                                          confirmText: '확인',
                                          confirmOnTap: () => context.pop(),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                        child: Container(
                          width: size.width,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: POINT_COLOR,
                          ),
                          child: Center(
                            child: buttonEnable
                                ? const Text(
                                    '평가 저장하기',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                : const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
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
        Text(
          '코치님께 전하고 싶은 내용을 적어주세요 📤',
          style: _titleStyle,
        ),
        const SizedBox(
          height: 12,
        ),
        TextFormField(
          maxLines: 9,
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
                ? ''
                : '운동관련 궁금증, 요청사항 등을 형식에 관계없이\n\n자유롭게 입력해주세요 😁\n\n\n\n\n\n\n\n\n',
            labelStyle: s2SubTitle.copyWith(
              color: focusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
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
        Text(
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
        Text(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
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
                  style: h6Headline.copyWith(
                    color: isSelected ? POINT_COLOR : GRAY_COLOR,
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
          style: h6Headline.copyWith(
            color: isSelected ? POINT_COLOR : GRAY_COLOR,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
