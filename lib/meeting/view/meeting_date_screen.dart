import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/home_screen.dart';
import 'package:fitend_member/meeting/model/meeting_date_model.dart';
import 'package:fitend_member/meeting/model/post_meeting_create_model.dart';
import 'package:fitend_member/meeting/provider/meeting_date_provider.dart';
import 'package:fitend_member/schedule/provider/schedule_provider.dart';
import 'package:fitend_member/trainer/model/get_trainer_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
      if (ref.read(meetingDateProvider(widget.trainerId))
          is MeetingDateModelError) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final endDate = today.add(const Duration(days: 5));

        await ref
            .read(meetingDateProvider(widget.trainerId).notifier)
            .getTrainerSchedules(widget.trainerId,
                GetTrainerScheduleModel(startDate: today, endDate: endDate));
      }
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
              SizedBox(
                width: 100.w,
                height: 380,
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
                            color:
                                isSelected ? Colors.white : Colors.transparent,
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
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          )),
                    );
                  },
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
              builder: (context) => DialogWidgets.oneButtonDialogBold(
                    message1:
                        '${DateFormat('M월 d일').format(selectStartTime)} (${weekday[selectStartTime.weekday - 1]}) ∙ ${selectStartTime.hour >= 12 ? ' 오후 ' : ' 오전 '}  ${DateFormat('h:mm').format(selectStartTime)}',
                    message2: '일정으로 미팅을 예약할까요?',
                    confirmText: '확인',
                    confirmOnTap: () {
                      context.pop();

                      ref
                          .read(meetingDateProvider(widget.trainerId).notifier)
                          .createMeeting(
                            PostMeetingCreateModel(
                              trainerId: widget.trainerId,
                              startTime: selectStartTime.toUtc(),
                              endTime: selectEndTime.toUtc(),
                            ),
                          );
                      DateTime fifteenDaysAgo =
                          DateTime.now().subtract(const Duration(days: 15));

                      ref.read(scheduleProvider.notifier).paginate(
                          startDate: DataUtils.getDate(fifteenDaysAgo));

                      context.goNamed(HomeScreen.routeName);
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
