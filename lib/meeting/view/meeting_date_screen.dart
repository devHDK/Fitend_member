import 'package:fitend_member/common/component/custom_one_button_dialog.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/home_screen.dart';
import 'package:fitend_member/meeting/model/meeting_date_model.dart';
import 'package:fitend_member/meeting/model/post_meeting_create_model.dart';
import 'package:fitend_member/meeting/provider/meeting_date_provider.dart';
import 'package:fitend_member/schedule/provider/schedule_provider.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/trainer/model/get_trainer_schedule_model.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingDateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'meetingDate';
  const MeetingDateScreen({
    super.key,
    required this.trainerId,
  });

  final int trainerId;

  @override
  ConsumerState<MeetingDateScreen> createState() => _MeetingDateScreenState();
}

class _MeetingDateScreenState extends ConsumerState<MeetingDateScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();

  int dateIndex = 0;
  int maxDateIndex = 0;
  DateTime selectStartTime = DateTime(2024);
  DateTime selectEndTime = DateTime(2024);
  bool buttonEnable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetch();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetch() async {
    if (mounted) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endDate = today.add(const Duration(days: 5));

      await ref
          .read(meetingDateProvider(widget.trainerId).notifier)
          .getTrainerSchedules(widget.trainerId,
              GetTrainerScheduleModel(startDate: today, endDate: endDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerScheduleState =
        ref.watch(meetingDateProvider(widget.trainerId));

    if (trainerScheduleState is MeetingDateModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (trainerScheduleState is MeetingDateModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: DialogWidgets.oneButtonDialog(
          message: trainerScheduleState.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final scheduleModel = trainerScheduleState as MeetingDateModel;
    maxDateIndex = scheduleModel.data.length - 1;

    buttonEnable = selectStartTime.isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SizedBox(
          width: 100.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
              ),
              Text(
                '가능하신 일정을 선택해주세요',
                style: h3Headline.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              _dateListBox(scheduleModel),
              _dateGridView(scheduleModel),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const _MeetingDatePickDialog(
                        message: '희망 일정을 선택해주시면\n빠르게 확인 후 연락드릴게요 🙏',
                        confirmText: '확인',
                      ),
                    );
                  },
                  child: Text(
                    '이중에 가능한 일정이 없어요 🥲',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: TextButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => CustomOneButtonDialog(
                    title:
                        '${DateFormat('M월 d일').format(selectStartTime)} (${weekday[selectStartTime.weekday - 1]}) ∙ ${selectStartTime.hour >= 12 ? ' 오후 ' : ' 오전 '}  ${DateFormat('h:mm').format(selectStartTime)}',
                    content: '일정으로 미팅을 예약할까요?',
                    confirmText: '확인',
                    confirmOnTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      pref.setBool(StringConstants.isNeedMeeting, false);

                      ref
                          .read(scheduleProvider.notifier)
                          .updateIsNeedMeeting(false);

                      try {
                        await ref
                            .read(
                                meetingDateProvider(widget.trainerId).notifier)
                            .createMeeting(
                              PostMeetingCreateModel(
                                trainerId: widget.trainerId,
                                startTime: selectStartTime.toUtc(),
                                endTime: selectEndTime.toUtc(),
                              ),
                            )
                            .then((value) {
                          DateTime fifteenDaysAgo =
                              DateTime.now().subtract(const Duration(days: 15));

                          ref
                              .read(scheduleProvider.notifier)
                              .paginate(startDate: fifteenDaysAgo);
                        });

                        if (!context.mounted) return;

                        context.goNamed(HomeScreen.routeName);
                      } catch (e) {
                        pref.setBool(StringConstants.isNeedMeeting, true);

                        ref
                            .read(scheduleProvider.notifier)
                            .updateIsNeedMeeting(true);

                        DialogWidgets.showToast(
                          content: '서버와 통신중 문제가 발생하였습니다.',
                          gravity: ToastGravity.CENTER,
                        );
                      }
                    },
                  ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: BoxDecoration(
              color:
                  buttonEnable ? Pallete.point : Pallete.point.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '예약 완료',
                style: h6Headline.copyWith(
                  color: buttonEnable
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _dateGridView(MeetingDateModel scheduleModel) {
    return SizedBox(
      width: 100.w,
      height: 100.h - 480,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0, // 가로축 아이템 간격
          mainAxisSpacing: 10.0, // 세로축 아이템 간격
          childAspectRatio: 4.0, // 아이템의 가로 세로 비율
        ),
        itemCount: scheduleModel.data[dateIndex].schedules.length,
        itemBuilder: (context, index) {
          final isAvail =
              scheduleModel.data[dateIndex].schedules[index].isAvail!;
          final data = scheduleModel.data[dateIndex].schedules[index];

          final isSelected = selectStartTime == data.startTime;

          return InkWell(
            onTap: isAvail
                ? () {
                    if (!mounted) return;

                    if (selectStartTime != data.startTime) {
                      selectStartTime = data.startTime;
                      selectEndTime = data.endTime;
                    } else {
                      selectStartTime = DateTime(2024);
                      selectEndTime = DateTime(2024);
                    }

                    setState(() {});
                  }
                : null,
            child: Container(
                width: 154,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: Border.all(
                    width: 1,
                    color: isSelected
                        ? Pallete.point
                        : isAvail
                            ? Pallete.gray
                            : Pallete.darkGray,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    DateFormat('hh:mm a').format(data.startTime),
                    style: s2SubTitle.copyWith(
                      color: isSelected
                          ? Pallete.point
                          : isAvail
                              ? Pallete.lightGray
                              : Pallete.darkGray,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      height: 1,
                    ),
                  ),
                )),
          );
        },
      ),
    );
  }

  Row _dateListBox(MeetingDateModel scheduleModel) {
    final width = (100.w - 48 - 56) / 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: dateIndex > 0
              ? () {
                  if (dateIndex > 0) {
                    if (mounted) {
                      setState(() {
                        dateIndex--;
                      });

                      if (dateIndex == 5 || dateIndex == 6) {
                        itemScrollController.jumpTo(index: 4);
                      } else {
                        itemScrollController.jumpTo(
                            index: dateIndex - (dateIndex == 0 ? 0 : 1));
                      }
                    }
                  }
                }
              : null,
          child: SizedBox(
            width: 24,
            height: 60,
            child: Icon(
              Icons.arrow_back_ios_sharp,
              color: dateIndex != 0 ? Colors.white : Colors.transparent,
              size: 15,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 105,
            child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (dateIndex != index) {
                      if (!mounted) return;

                      setState(() {
                        dateIndex = index;
                      });
                    }
                  },
                  child: SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 66,
                            child: Center(
                              child: Text(
                                '${weekday[scheduleModel.data[index].startDate.weekday - 1]}\n${DateFormat('MM / dd').format(scheduleModel.data[index].startDate)}',
                                style: s2SubTitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: dateIndex == index
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            height: 4,
                            color: dateIndex == index
                                ? Pallete.point
                                : Pallete.lightGray,
                          ),
                          const SizedBox(
                            height: 34,
                          )
                        ],
                      )),
                );
              },
              itemCount: scheduleModel.data.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        InkWell(
          onTap: dateIndex < maxDateIndex
              ? () {
                  if (dateIndex < maxDateIndex) {
                    if (mounted) {
                      setState(() {
                        dateIndex++;
                      });

                      if (dateIndex == maxDateIndex - 1 ||
                          dateIndex == maxDateIndex) {
                        itemScrollController.jumpTo(index: 4);
                      } else {
                        itemScrollController.jumpTo(
                            index: dateIndex - (dateIndex == 0 ? 0 : 1));
                      }
                    }
                  }
                }
              : null,
          child: SizedBox(
            width: 24,
            height: 60,
            child: Icon(
              Icons.arrow_forward_ios_sharp,
              color: dateIndex != scheduleModel.data.length - 1
                  ? Colors.white
                  : Colors.transparent,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _MeetingDatePickDialog extends ConsumerStatefulWidget {
  const _MeetingDatePickDialog({
    required this.message,
    required this.confirmText,
  });
  final String message;
  final String confirmText;

  @override
  ConsumerState<_MeetingDatePickDialog> createState() =>
      _MeetingDatePickDialogState();
}

class _MeetingDatePickDialogState
    extends ConsumerState<_MeetingDatePickDialog> {
  DateTime selectDate = DateTime.now().add(const Duration(hours: 2));
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(getMeProvider) as UserModel;
    // final threadCreate = ref.watch(threadCreateProvider);

    return DialogBackground(
      blur: 0.2,
      dismissable: true,
      dialog: SimpleDialog(
        insetPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        backgroundColor: Colors.transparent,
        children: [
          Container(
            width: 335,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.message,
                    style: s1SubTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          final pickTime = await _dateTimePicker();

                          if (pickTime != null && mounted) {
                            setState(() {
                              selectDate = pickTime;
                            });
                          }
                        },
                        child: Container(
                          height: 25,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(SVGConstants.calendar,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${DateFormat('yyyy.MM.dd').format(selectDate)} ${weekday[selectDate.weekday - 1]} ',
                                style: h6Headline.copyWith(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final pickTime = await _dateTimePicker();

                          if (pickTime != null && mounted) {
                            setState(() {
                              selectDate = pickTime;
                            });
                          }
                        },
                        child: Container(
                          height: 25,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(SVGConstants.timer,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                DateFormat('hh:mm a').format(selectDate),
                                style: h6Headline.copyWith(),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: !isLoading
                        ? () async {
                            setState(() {
                              isLoading = true;
                            });

                            final pref = await SharedPreferences.getInstance();
                            pref.setBool(StringConstants.isNeedMeeting, false);

                            ref
                                .read(scheduleProvider.notifier)
                                .updateIsNeedMeeting(false);

                            try {
                              ref
                                  .read(threadCreateProvider.notifier)
                                  .updateTitle('온보딩 미팅 희망일정');

                              ref.read(threadCreateProvider.notifier).updateContent(
                                  '${DateFormat('yyyy년 M월 d일').format(selectDate)} (${weekday[selectDate.weekday - 1]}) ∙${selectDate.hour >= 12 ? ' 오후 ' : ' 오전 '}${DateFormat('h:mm').format(selectDate)}');

                              await ref
                                  .read(threadCreateProvider.notifier)
                                  .createThread(
                                    user: ThreadUser(
                                      id: userModel.user.id,
                                      nickname: userModel.user.nickname,
                                      gender: userModel.user.gender,
                                    ),
                                    trainer: ThreadTrainer(
                                      id: userModel
                                          .user.activeTrainers.first.id,
                                      nickname: userModel
                                          .user.activeTrainers.first.nickname,
                                      profileImage: userModel.user
                                          .activeTrainers.first.profileImage,
                                    ),
                                    isMeetingThread: true,
                                  )
                                  .then((value) {
                                DialogWidgets.showToast(
                                  content: '미팅 희망일 확인후 연락 드릴게요 😀',
                                  gravity: ToastGravity.CENTER,
                                );
                                context.goNamed(HomeScreen.routeName);
                              });
                            } catch (e) {
                              final pref =
                                  await SharedPreferences.getInstance();
                              pref.setBool(StringConstants.isNeedMeeting, true);

                              ref
                                  .read(scheduleProvider.notifier)
                                  .updateIsNeedMeeting(true);
                              setState(() {
                                isLoading = false;
                              });
                              DialogWidgets.showToast(
                                  content: '서버와 통신중 에러가 발생했습니다.');
                            }
                          }
                        : null,
                    child: Container(
                      width: 279,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Pallete.point,
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.confirmText,
                                style: h6Headline.copyWith(
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _dateTimePicker() async {
    final pickTime = await picker.DatePicker.showDateTimePicker(
      context,
      locale: picker.LocaleType.ko,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(
        const Duration(days: 13),
      ),
      theme: picker.DatePickerTheme(
        backgroundColor: Pallete.background,
        itemStyle: h2Headline.copyWith(
          color: Colors.white,
        ),
        doneStyle: s2SubTitle.copyWith(
          color: Colors.white,
        ),
        cancelStyle: s2SubTitle.copyWith(
          color: Colors.white,
        ),
      ),
    );

    if (pickTime != null) {
      return pickTime;
    } else {
      return null;
    }
  }
}
