import 'dart:io';

import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmojiButton extends StatefulWidget {
  final int? count;
  final String? emoji;
  final bool? isSelected;
  final GestureTapCallback onTap;

  const EmojiButton({
    super.key,
    this.count,
    this.emoji,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
              widget.isSelected! ? const Color(0xffCA3850) : Pallete.darkGray,
        ),
        child: widget.emoji == null
            ? Center(child: SvgPicture.asset(SVGConstants.emojiButton))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.emoji! + widget.count!.toString(),
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                      letterSpacing: Platform.isIOS ? 0 : 3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
