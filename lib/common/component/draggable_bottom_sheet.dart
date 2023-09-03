import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

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
    Size size = MediaQuery.of(context).size;
    return Container(
      height: widget.isSwipeUp ? MediaQuery.of(context).size.height : 195,
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
                    color: LIGHT_GRAY_COLOR,
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
