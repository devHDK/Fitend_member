import 'dart:ffi';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:math';

import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.secondsGoal,
    required this.secondsRecord,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final int secondsGoal;
  final int secondsRecord;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late ValueNotifier<double> valueNotifier;

  @override
  void initState() {
    super.initState();
    valueNotifier = ValueNotifier(
        (widget.secondsRecord.toDouble() / widget.secondsRecord.toDouble()));
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.model.exercises[widget.model.exerciseIndex].name,
          style: h4Headline.copyWith(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 55,
            ),
            Text(
              '${widget.setInfoIndex + 1} SET',
              style: h2Headline,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '${(widget.model.modifiedExercises[widget.model.exerciseIndex].setInfo[widget.setInfoIndex].seconds! / 60).floor()} 분 ${(widget.model.modifiedExercises[widget.model.exerciseIndex].setInfo[widget.setInfoIndex].seconds! % 60).toString().padLeft(2, '0')} 초',
              style: s1SubTitle.copyWith(
                color: GRAY_COLOR,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            SimpleCircularProgressBar(
              animationDuration: 0,
              size: 220,
              backColor: POINT_COLOR.withOpacity(0.1),
              backStrokeWidth: 20,
              progressStrokeWidth: 20,
              progressColors: [POINT_COLOR, POINT_COLOR.withOpacity(0.5)],
              valueNotifier: valueNotifier,
              maxValue: 1,
            ),
            const SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: POINT_COLOR.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SvgPicture.asset('asset/img/icon_reset.svg'),
                        ),
                      ),
                    ),
                    Text(
                      'Reset',
                      style: s2SubTitle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: POINT_COLOR.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SvgPicture.asset('asset/img/icon_exit.svg'),
                        ),
                      ),
                    ),
                    Text(
                      'Exit',
                      style: s2SubTitle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
