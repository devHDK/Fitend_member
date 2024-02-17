import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/user/component/survey_button.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NextWeekScheduleScreen extends ConsumerStatefulWidget {
  static String get routeName => 'next_workout';

  const NextWeekScheduleScreen({super.key});

  @override
  ConsumerState<NextWeekScheduleScreen> createState() =>
      _NextWeekScheduleState();
}

class _NextWeekScheduleState extends ConsumerState<NextWeekScheduleScreen> {
  List<DateTime> selectedDates = [];
  bool noSchedule = false;
  bool alreadyShared = false;
  bool isLoading = false;
  bool buttonEnable = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);

    if (state is UserModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (state is UserModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: DialogWidgets.oneButtonDialog(
            message: '서버와 통신중 문제가 발생하였습니다.',
            confirmText: '확인',
            confirmOnTap: () => context.pop(),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final nextWeekMonday = today.add(Duration(days: 8 - today.weekday));
    List<DateTime> dates = [];

    for (int index = 0; index < 7; index++) {
      final tempDate = nextWeekMonday.add(Duration(days: index));

      dates.add(tempDate);
    }

    final userModel = state as UserModel;

    buttonEnable = selectedDates.isNotEmpty || alreadyShared || noSchedule;

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 25,
            ),
            Text(
              '다음주는 어떤 요일에 운동하세요?',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(
              height: 25,
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  if (index == 7) {
                    return SurveyButton(
                      content: '일정이 있어서 다음주는 쉴게요 😇',
                      onTap: () {
                        selectedDates = [];
                        noSchedule = true;
                        alreadyShared = false;
                        setState(() {});
                      },
                      isSelected: noSchedule,
                    );
                  }

                  if (index == 8) {
                    return SurveyButton(
                      content: '이미 코치님께 일정을 공유했어요 🗣️️',
                      onTap: () {
                        selectedDates = [];
                        alreadyShared = true;
                        noSchedule = false;
                        setState(() {});
                      },
                      isSelected: alreadyShared,
                    );
                  }
                  return SurveyButton(
                    content:
                        '${DateFormat('M월 d일').format(dates[index])} (${weekday[dates[index].weekday - 1]}요일)',
                    onTap: () {
                      noSchedule = false;

                      if (selectedDates.contains(dates[index])) {
                        selectedDates.remove(dates[index]);
                      } else {
                        selectedDates.add(dates[index]);
                      }

                      if (selectedDates.length >= 2) {
                        selectedDates.sort((a, b) => a.compareTo(b));
                      }

                      setState(() {});
                    },
                    isSelected: selectedDates.contains(dates[index]),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 12,
                ),
                itemCount: 9,
              ),
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: buttonEnable && !isLoading
            ? () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  await ref.read(getMeProvider.notifier).postNextWorkout(
                        mondayDate: dates[0],
                        selectedDates: selectedDates,
                        noSchedule: noSchedule,
                      );

                  if (!alreadyShared) {
                    ref.read(threadCreateProvider.notifier).init();
                    ref
                        .read(threadCreateProvider.notifier)
                        .updateTitle('다음주 운동 스케줄');

                    if (noSchedule) {
                      ref
                          .read(threadCreateProvider.notifier)
                          .updateContent('일정이 있어서 다음주는 쉴게요 😇');
                    } else {
                      List<String> dateStringList = [];
                      for (var date in selectedDates) {
                        dateStringList.add(
                          DateFormat('M/d (${weekday[date.weekday - 1]})')
                              .format(date),
                        );
                      }
                      ref
                          .read(threadCreateProvider.notifier)
                          .updateContent(dateStringList.join(' ∙ '));
                    }

                    await ref.read(threadCreateProvider.notifier).createThread(
                          user: ThreadUser(
                            id: userModel.user.id,
                            nickname: userModel.user.nickname,
                            gender: userModel.user.gender,
                          ),
                          trainer: ThreadTrainer(
                            id: userModel.user.activeTrainers.first.id,
                            nickname:
                                userModel.user.activeTrainers.first.nickname,
                            profileImage: userModel
                                .user.activeTrainers.first.profileImage,
                          ),
                        );
                  }

                  if (!context.mounted) return;

                  ref
                      .read(getMeProvider.notifier)
                      .updateIsWorkoutSurvey(isWorkoutSurvey: true);

                  DialogWidgets.showToast(
                    content: '운동일정을 전달했어요 ✅',
                    gravity: ToastGravity.CENTER,
                  );

                  context.pop();
                } catch (e) {
                  DialogWidgets.showToast(
                    content: '다시 시도해주세요',
                    gravity: ToastGravity.CENTER,
                  );

                  setState(() {
                    isLoading = false;
                  });
                }
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: BoxDecoration(
              color:
                  buttonEnable ? Pallete.point : Pallete.point.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      '완료',
                      style: h6Headline.copyWith(
                        color: buttonEnable
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
