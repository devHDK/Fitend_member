import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fitend_member/common/component/calendar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/schedule/model/put_workout_schedule_date_model.dart';
import 'package:fitend_member/schedule/model/schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ndialog/ndialog.dart';
import 'package:flutter/foundation.dart' as foundation;

class DialogWidgets {
  static DialogBackground confirmDialog({
    required String message,
    required String confirmText,
    required String cancelText,
    required GestureTapCallback confirmOnTap,
    required GestureTapCallback cancelOnTap,
    bool? dismissable = true,
  }) {
    return DialogBackground(
      blur: 0.2,
      dismissable: dismissable,
      dialog: SimpleDialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        children: [
          Container(
            width: 335,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Text(
                    message,
                    style: s2SubTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: confirmOnTap,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: POINT_COLOR,
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: h6Headline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: cancelOnTap,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: POINT_COLOR),
                      ),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: h6Headline.copyWith(
                            color: POINT_COLOR,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static DialogBackground errorDialog({
    required String message,
    required String confirmText,
    required GestureTapCallback confirmOnTap,
    bool? dismissable = true,
  }) {
    return DialogBackground(
      blur: 0.2,
      dismissable: dismissable,
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
                children: [
                  Text(
                    message,
                    style: s2SubTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: confirmOnTap,
                    child: Container(
                      width: 279,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: POINT_COLOR,
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
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

  static DialogBackground progressDialog({
    required int totalCount,
    required int doneCount,
  }) {
    return DialogBackground(
      blur: 0.2,
      dismissable: false,
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
                child: CircularProgressIndicator(
                  color: POINT_COLOR,
                  value: doneCount / totalCount,
                )),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> emojiPickerDialog({
    required BuildContext context,
    required Function(Category? category, Emoji? emoji) onEmojiSelect,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 250,
          child: EmojiPicker(
            onEmojiSelected: onEmojiSelect,
            config: Config(
              columns: 7,
              emojiSizeMax: 32 *
                  (foundation.defaultTargetPlatform == TargetPlatform.iOS
                      ? 1.30
                      : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: BACKGROUND_COLOR,
              indicatorColor: POINT_COLOR,
              iconColor: Colors.grey,
              iconColorSelected: POINT_COLOR,
              backspaceColor: POINT_COLOR,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              recentTabBehavior: RecentTabBehavior.RECENT,
              recentsLimit: 28,
              noRecents: const Text(
                'No Recents',
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              loadingIndicator:
                  const SizedBox.shrink(), // Needs to be const Widget
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL,
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarDialog extends ConsumerStatefulWidget {
  const CalendarDialog({
    super.key,
    required this.scheduleDate,
    required this.workoutScheduleId,
  });

  final DateTime scheduleDate;
  final int workoutScheduleId;

  @override
  ConsumerState<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends ConsumerState<CalendarDialog> {
  DateTime? selectedDay;
  DateTime? focusedDay;
  DateTime? firstDay;
  DateTime? lastDay;
  Map<String, List<dynamic>>? dateData = {};
  DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    selectedDay = widget.scheduleDate;
    focusedDay = widget.scheduleDate;

    firstDay = widget.scheduleDate
                    .subtract(Duration(days: widget.scheduleDate.weekday - 1))
                    .compareTo(today) <=
                0 &&
            widget.scheduleDate
                    .add(Duration(days: 7 - widget.scheduleDate.weekday))
                    .compareTo(today) >=
                0
        ? today
        : widget.scheduleDate
            .subtract(Duration(days: widget.scheduleDate.weekday - 1));
    lastDay = widget.scheduleDate
        .add(Duration(days: 7 - widget.scheduleDate.weekday));
  }

  void changeScheduleDate() async {
    try {
      await ref.read(workoutScheduleRepositoryProvider).putworkoutScheduleDate(
            id: widget.workoutScheduleId,
            body: PutWorkoutScheduleModel(
              startDate: intl.DateFormat('yyyy-MM-dd').format(selectedDay!),
              seq:
                  dateData!["${selectedDay!.month}-${selectedDay!.day}"] == null
                      ? 1
                      : dateData!["${selectedDay!.month}-${selectedDay!.day}"]!
                              .length +
                          1,
            ),
          );

      //이전 스케줄 인덱스
      final beforeChangeScheduleIndex =
          scheduleListGlobal.indexWhere((element) {
        return element.startDate == widget.scheduleDate;
      });

      //이전 워크아웃 인덱스
      final beforWorkoutIndex = scheduleListGlobal[beforeChangeScheduleIndex]
          .schedule!
          .indexWhere((element) {
        if (element is Workout) {
          return element.workoutScheduleId == widget.workoutScheduleId;
        }

        return false;
      });

      //변경할 날짜의 스케줄 인덱스
      final afterCahngeSchdedulIndex = scheduleListGlobal.indexWhere((element) {
        final localTime =
            intl.DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(selectedDay!);
        return element.startDate == DateTime.parse(localTime);
      });

      //변경
      scheduleListGlobal[afterCahngeSchdedulIndex].schedule!.add(
          scheduleListGlobal[beforeChangeScheduleIndex]
              .schedule![beforWorkoutIndex]);

      //기존건 삭제
      scheduleListGlobal[beforeChangeScheduleIndex]
          .schedule!
          .removeAt(beforWorkoutIndex);
    } catch (e) {
      // debugPrint(e);

      showDialog(
        context: context,
        builder: (context) => DialogWidgets.errorDialog(
          message: '오류가 발생하였습니다 다시 시도해주세요!',
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ScheduleData> scheduleList = [];
    if (firstDay != null && lastDay != null) {
      scheduleList = scheduleListGlobal
          .where((element) =>
              element.startDate.compareTo(firstDay!) >= 0 &&
              element.startDate.compareTo(lastDay!) <= 0 &&
              element.schedule!.isNotEmpty)
          .toList();
    }

    Map<String, List<dynamic>> dateMap = {
      for (var data in scheduleList)
        "${data.startDate.month}-${data.startDate.day}": data.schedule!
    };

    dateData = dateMap;

    return DialogBackground(
      blur: 0.2,
      dialog: Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            width: 319,
            height: 460,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Calendar(
                    schedules: scheduleList,
                    scheduleDate: widget.scheduleDate,
                    focusedDay:
                        focusedDay != null ? focusedDay! : widget.scheduleDate,
                    selectedDay: selectedDay != null ? selectedDay! : null,
                    firstDay: firstDay ?? firstDay!,
                    lastDay: lastDay ?? lastDay!,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        this.selectedDay = selectedDay;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (selectedDay != null &&
                              selectedDay!.compareTo(widget.scheduleDate) !=
                                  0) {
                            changeScheduleDate();
                            context.pop({'changedDate': selectedDay});
                          } else {
                            // debugPrint('오늘날짜 선택!');
                            showDialog(
                              context: context,
                              builder: (context) => DialogWidgets.errorDialog(
                                message: '기존 스케줄 이외의 날짜를 선택해주세요!',
                                confirmText: '확인',
                                confirmOnTap: () => context.pop(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
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
}
