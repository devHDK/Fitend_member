import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomTimerPicker extends StatefulWidget {
  final int seconds;

  const CustomTimerPicker({
    super.key,
    required this.seconds,
  });

  @override
  State<CustomTimerPicker> createState() => _CustomTimerPickerState();
}

class _CustomTimerPickerState extends State<CustomTimerPicker> {
  int min = 0;
  int sec = 0;

  @override
  void initState() {
    super.initState();

    min = (widget.seconds / 60).floor();
    sec = (widget.seconds % 60);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumberPicker(
                haptics: true,
                textStyle: h1Headline.copyWith(color: Pallete.gray),
                selectedTextStyle: h1Headline.copyWith(
                  color: Pallete.point,
                ),
                minValue: 0,
                maxValue: 100,
                value: min,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      min = value;
                    });
                  }
                },
              ),
              Text(
                'min',
                style: s1SubTitle.copyWith(
                  fontSize: 22,
                ),
              ),
              NumberPicker(
                haptics: true,
                textStyle: h1Headline.copyWith(color: Pallete.gray),
                selectedTextStyle: h1Headline.copyWith(
                  color: Pallete.point,
                ),
                minValue: 0,
                maxValue: 59,
                value: sec,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      sec = value;
                    });
                  }
                },
              ),
              Text(
                'sec',
                style: s1SubTitle.copyWith(
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Container(
                  width: 40.w,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Pallete.gray,
                  ),
                  child: Center(
                    child: Text(
                      '취소',
                      style: h2Headline.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.pop(min * 60 + sec);
                },
                child: Container(
                  width: 40.w,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Pallete.point,
                  ),
                  child: Center(
                    child: Text(
                      '완료',
                      style: h2Headline.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
