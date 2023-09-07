import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NumberPicker(
            haptics: true,
            textStyle: h1Headline.copyWith(color: GRAY_COLOR),
            selectedTextStyle: h1Headline.copyWith(
              color: POINT_COLOR,
            ),
            minValue: 0,
            maxValue: 100,
            value: min,
            onChanged: (value) {
              setState(() {
                min = value;
              });
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
            textStyle: h1Headline.copyWith(color: GRAY_COLOR),
            selectedTextStyle: h1Headline.copyWith(
              color: POINT_COLOR,
            ),
            minValue: 0,
            maxValue: 59,
            value: sec,
            onChanged: (value) {
              setState(() {
                sec = value;
              });
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
    );
  }
}
