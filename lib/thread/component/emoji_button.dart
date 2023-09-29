import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmojiButton extends StatefulWidget {
  int? count;
  String? emoji;
  Color? color;
  final GestureTapCallback onTap;

  EmojiButton({
    super.key,
    this.count,
    this.emoji,
    this.color = DARK_GRAY_COLOR,
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
          color: widget.color,
        ),
        child: widget.emoji == null
            ? Center(child: SvgPicture.asset('asset/img/icon_emoji_button.svg'))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.emoji! + widget.count!.toString(),
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
