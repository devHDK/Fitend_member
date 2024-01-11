import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime date;

  const CustomDatePicker({
    super.key,
    required this.date,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void initState() {
    super.initState();

    year = widget.date.year;
    month = widget.date.month;
    day = widget.date.day;
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
                minValue: 1930,
                maxValue: DateTime.now().year,
                value: year,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      year = value;
                    });
                  }
                },
              ),
              Text(
                '∙',
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
                minValue: 1,
                maxValue: 12,
                value: month,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      month = value;
                    });
                  }
                },
              ),
              Text(
                '∙',
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
                minValue: 1,
                maxValue: 31,
                value: day,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      day = value;
                    });
                  }
                },
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
                  context.pop(DateTime(year, month, day));
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
