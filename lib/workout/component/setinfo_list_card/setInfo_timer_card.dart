import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/hexagon_container.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/component/custom_timer_picker.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
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
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final int initialSeconds;
  final int workoutScheduleId;

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
    final isNowSet = widget.setInfoIndex ==
        widget.model.setInfoCompleteList[widget.model.exerciseIndex];

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
                              );
                            },
                          ),
                          const SizedBox(
                            width: 45,
                          ),
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset(
                              'asset/img/icon_clock.svg',
                              color: isNowSet ? POINT_COLOR : GRAY_COLOR,
                              width: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          AutoSizeText(
                            '${(widget.initialSeconds / 60).floor().toString().padLeft(2, '0')} : ${(widget.initialSeconds % 60).toString().padLeft(2, '0')} ',
                            style: h2Headline.copyWith(
                              height: 1.2,
                              color: isNowSet ? Colors.black : GRAY_COLOR,
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
      height: 200,
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
