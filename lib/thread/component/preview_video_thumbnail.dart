import 'dart:io';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:flutter/material.dart';

class PreviewVideoThumbNail extends StatefulWidget {
  const PreviewVideoThumbNail({
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
  State<PreviewVideoThumbNail> createState() => _PreviewVideoThumbNailState();
}

class _PreviewVideoThumbNailState extends State<PreviewVideoThumbNail> {
  // VideoPlayerController? _videoController;
  File? thumbNail;
  double fileSize = 0.0;

  @override
  void didUpdateWidget(covariant PreviewVideoThumbNail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file != widget.file) {
      setThumbNail();
    }
  }

  @override
  void initState() {
    super.initState();
    // _videoController = VideoPlayerController.file(widget.file);
    setThumbNail();
    getSize(widget.file);
  }

  @override
  void dispose() {
    // _videoController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: widget.isBorder!
              ? BoxDecoration(
                  border: Border.all(
                    color: POINT_COLOR,
                    width: 2,
                  ),
                )
              : null,
          width: widget.width!.toDouble(),
          height: widget.width!.toDouble() * 0.8,
          child: ClipRRect(
            borderRadius: widget.isCircle!
                ? BorderRadius.circular(12)
                : BorderRadius.circular(0),
            child: thumbNail != null
                ? Image.file(
                    thumbNail!,
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: POINT_COLOR,
                    ),
                  ),
          ),
        ),
        Positioned(
          left: 5,
          bottom: 1,
          child: Icon(
            Icons.videocam,
            color: Colors.black.withOpacity(0.6),
            size: 22,
          ),
        ),
        Positioned(
          right: 8,
          bottom: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Row(
                children: [
                  Text(
                    '${fileSize}MB',
                    style: c2Caption.copyWith(
                      color: fileSize < 400 ? Colors.white : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void setThumbNail() async {
    final filePath = await MediaUtils.getVideoThumbNail(widget.file.path);
    if (filePath != null) {
      thumbNail = File(filePath);
      getSize(File(widget.file.path));
      // debugPrint('thumbnail path ===> ${thumbNail!.path}');
    }
  }

  void getSize(File file) async {
    final fileBytes = await file.length();

    setState(() {
      fileSize = double.parse((fileBytes / (1000 * 1000)).toStringAsFixed(1));
    });
  }
}
