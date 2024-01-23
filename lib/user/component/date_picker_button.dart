import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DatePickerbutton extends StatelessWidget {
  const DatePickerbutton({
    super.key,
    required this.content,
    required this.onTap,
  });

  final String content;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100.w,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: Pallete.darkGray,
              ),
              color: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: Text(
                  content,
                  style: s2SubTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 11,
            child: SvgPicture.asset(
              SVGConstants.calendar,
            ),
          ),
        ],
      ),
    );
  }
}
