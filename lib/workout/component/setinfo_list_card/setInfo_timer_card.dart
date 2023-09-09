import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/hexagon_container.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/component/custom_timer_picker.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/view/timer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SetInfoBoxForTimer extends ConsumerStatefulWidget {
  const SetInfoBoxForTimer({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.initialSeconds,
    required this.workoutScheduleId,
    required this.refresh,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final int initialSeconds;
  final int workoutScheduleId;
  final Function refresh;

  @override
  ConsumerState<SetInfoBoxForTimer> createState() => _SetInfoBoxForTimerState();
}

class _SetInfoBoxForTimerState extends ConsumerState<SetInfoBoxForTimer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerXMoreBox = ref.read(hiveTimerXMoreRecordProvider);

    final isNowSet = widget.setInfoIndex ==
        widget.model.setInfoCompleteList[widget.model.exerciseIndex];

    SetInfo recordSetInfo = SetInfo(index: widget.setInfoIndex + 1);

    timerXMoreBox.whenData((value) {
      final record = value.get(
          widget.model.exercises[widget.model.exerciseIndex].workoutPlanId);

      if (record is WorkoutRecordSimple) {
        recordSetInfo = record.setInfo[widget.setInfoIndex];
        print(recordSetInfo.seconds);
      }
    });

    return Column(
      children: [
        SizedBox(
          height: 85,
          width: 100.w - 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 40,
                    width: 1,
                    color: LIGHT_GRAY_COLOR,
                  ),
                  HexagonContainer(
                    label: (widget.setInfoIndex + 1).toString(),
                    labelColor: isNowSet ? Colors.black : GRAY_COLOR,
                    color: isNowSet ? Colors.white : LIGHT_GRAY_COLOR,
                    lineColor: isNowSet ? POINT_COLOR : LIGHT_GRAY_COLOR,
                    size: 39,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Container(
                    height: 4,
                    width: 1,
                    color: LIGHT_GRAY_COLOR,
                  ),
                ],
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  Container(
                    width: 100.w - 110,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: widget.setInfoIndex ==
                                widget.model.setInfoCompleteList[
                                    widget.model.exerciseIndex]
                            ? POINT_COLOR
                            : Colors.white,
                        width: 3,
                      ),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: 100.w - 110,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          SvgPicture.asset('asset/img/icon_target.svg'),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            child: AutoSizeText(
                              '${(widget.initialSeconds / 60).floor().toString().padLeft(2, '0')} : ${(widget.initialSeconds % 60).toString().padLeft(2, '0')} ',
                              style: s2SubTitle.copyWith(
                                color: GRAY_COLOR,
                                height: 1.1,
                              ),
                            ),
                            onTap: () async {
                              await showCupertinoModalPopup<int>(
                                context: context,
                                builder: (BuildContext context) {
                                  return _buildContainer(
                                    CustomTimerPicker(
                                      seconds: widget.initialSeconds,
                                    ),
                                  );
                                },
                              ).then((seconds) {
                                if (seconds != null) {
                                  ref
                                      .read(workoutProcessProvider(
                                              widget.workoutScheduleId)
                                          .notifier)
                                      .modifiedSecondsGoal(
                                          seconds, widget.setInfoIndex);

                                  widget.refresh();
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            width: 45,
                          ),
                          InkWell(
                            onTap: isNowSet
                                ? () {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) => TimerScreen(
                                        model: widget.model,
                                        setInfoIndex: widget.setInfoIndex,
                                        secondsGoal: widget.initialSeconds,
                                        secondsRecord: recordSetInfo.seconds!,
                                        workoutScheduleId:
                                            widget.workoutScheduleId,
                                        refresh: widget.refresh,
                                      ),
                                      fullscreenDialog: true,
                                    ));
                                  }
                                : null,
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset(
                                'asset/img/icon_clock.svg',
                                color: isNowSet ? POINT_COLOR : GRAY_COLOR,
                                width: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () async {
                              await showCupertinoModalPopup<int>(
                                context: context,
                                builder: (BuildContext context) {
                                  return _buildContainer(
                                    CustomTimerPicker(
                                      seconds: recordSetInfo.seconds!,
                                    ),
                                  );
                                },
                              ).then((seconds) {
                                if (seconds != null) {
                                  ref
                                      .read(workoutProcessProvider(
                                              widget.workoutScheduleId)
                                          .notifier)
                                      .modifiedSecondsRecord(
                                          seconds, widget.setInfoIndex);

                                  recordSetInfo.seconds = seconds;

                                  widget.refresh();
                                }
                              });
                            },
                            child: AutoSizeText(
                              '${(recordSetInfo.seconds! / 60).floor().toInt().toString().padLeft(2, '0')} : ${(recordSetInfo.seconds! % 60).toInt().toString().padLeft(2, '0')} ',
                              style: h2Headline.copyWith(
                                height: 1.2,
                                color: isNowSet ? Colors.black : GRAY_COLOR,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        if (widget.setInfoIndex ==
            widget.model.exercises[widget.model.exerciseIndex].setInfo.length -
                1)
          Container(
            height: 100,
          )
      ],
    );
  }

  Widget _buildContainer(Widget picker) {
    return Container(
      height: 260,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }
}
