import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SurveyButton extends StatelessWidget {
  const SurveyButton({
    super.key,
    required this.content,
    required this.onTap,
    required this.isSelected,
    this.textAlign = TextAlign.start,
    this.width,
  });

  final String content;
  final GestureTapCallback onTap;
  final bool isSelected;
  final double? width;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 100.w,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: isSelected ? Pallete.point : Pallete.darkGray,
          ),
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            content,
            textAlign: textAlign,
            style: s2SubTitle.copyWith(
              color: isSelected ? Pallete.point : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
