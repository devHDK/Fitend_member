import 'dart:io';

import 'package:fitend_member/common/const/pallete.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {
  const PreviewImage({
    super.key,
    required this.file,
    this.isCircle = true,
    this.isBorder = false,
    this.width = 140,
  });

  final File file;
  final bool? isCircle;
  final bool? isBorder;
  final int? width;

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  void didUpdateWidget(covariant PreviewImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width!.toDouble(),
      height: widget.width!.toDouble() * 0.8,
      decoration: widget.isBorder!
          ? BoxDecoration(
              border: Border.all(
                color: Pallete.point,
                width: 2,
              ),
            )
          : null,
      child: ClipRRect(
        borderRadius: widget.isCircle!
            ? BorderRadius.circular(12)
            : BorderRadius.circular(0),
        child: Image.file(
          widget.file,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
