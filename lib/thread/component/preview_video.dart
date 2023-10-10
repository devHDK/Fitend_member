import 'dart:io';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  const PreviewVideo({
    super.key,
    required this.file,
  });

  final File file;

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  // VideoPlayerController? _videoController;
  File? thumbNail;

  @override
  void didUpdateWidget(covariant PreviewVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      setState(() {});
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
        SizedBox(
          width: 140,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
      print(thumbNail!.path);
    }

    setState(() {});
  }
}
