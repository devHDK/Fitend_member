import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlaceButton extends StatelessWidget {
  const PlaceButton({
    super.key,
    required this.content,
    required this.onTap,
    required this.isSelected,
  });

  final String content;
  final GestureTapCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: isSelected ? Pallete.point : Pallete.darkGray,
          ),
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: s2SubTitle.copyWith(
                color: isSelected ? Pallete.point : Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
