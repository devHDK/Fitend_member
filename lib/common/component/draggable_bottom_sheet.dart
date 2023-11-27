import 'package:fitend_member/common/const/pallete.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomDraggableBottomSheet extends StatefulWidget {
  final bool isSwipeUp;
  final Widget? content;

  const CustomDraggableBottomSheet({
    super.key,
    required this.isSwipeUp,
    this.content,
  });

  @override
  State<CustomDraggableBottomSheet> createState() =>
      _CustomDraggableBottomSheetState();
}

class _CustomDraggableBottomSheetState
    extends State<CustomDraggableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    Size size = Size(100.w, 100.h);
    return Container(
      height: widget.isSwipeUp ? 100.h : 195,
      width: size.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
              ),
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: Pallete.lightGray,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          if (widget.content != null) widget.content!,
        ],
      ),
    );
  }
}
