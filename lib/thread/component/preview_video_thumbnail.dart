import 'dart:io';

import 'package:fitend_member/common/const/colors.dart';
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
  }

  @override
  void dispose() {
    // _videoController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
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
                    ? BorderRadius.circular(20)
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
            const Positioned(
              left: 5,
              bottom: 5,
              child: Icon(
                Icons.videocam,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }

  void setThumbNail() async {
    final filePath = await MediaUtils.getVideoThumbNail(widget.file.path);
    if (filePath != null) {
      thumbNail = File(filePath);
      // debugPrint('thumbnail path ===> ${thumbNail!.path}');
    }

    setState(() {});
  }
}
