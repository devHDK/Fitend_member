import 'dart:io';

import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {
  const PreviewImage({
    super.key,
    required this.file,
  });

  final File file;

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
    return Row(children: [
      SizedBox(
        width: 140,
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            widget.file,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(
        width: 10,
      )
    ]);
  }
}
