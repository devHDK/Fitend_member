import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoTicketCell extends StatelessWidget {
  const NoTicketCell({
    super.key,
    required this.title,
    required this.content,
    this.child,
  });

  final String title;
  final String content;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Pallete.lightGray,
          ),
          child: Center(
            child: SvgPicture.asset(
              SVGConstants.ticket,
              width: 28,
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: s1SubTitle.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              content,
              style: s2SubTitle.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (child != null)
          Align(
            alignment: Alignment.centerRight,
            child: child,
          )
      ],
    );
  }
}
