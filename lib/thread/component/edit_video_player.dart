import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/thread/view/video_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

class EditVideoPlayer extends ConsumerStatefulWidget {
  final File file;
  final int index;
  final bool? isComment;
  final int? threadId;
  const EditVideoPlayer({
    super.key,
    required this.file,
    required this.index,
    this.isComment = false,
    this.threadId,
  });

  @override
  ConsumerState<EditVideoPlayer> createState() => _EditVideoPlayerState();
}

class _EditVideoPlayerState extends ConsumerState<EditVideoPlayer> {
  VideoPlayerController? _videoController;

  Duration currentPosition = const Duration();
  bool isShowControlls = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    videoInit();
  }

  @override
  void dispose() {
    _videoController!.removeListener(videoListener);
    _videoController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EditVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.file != widget.file) {
      _videoController!.removeListener(videoListener);
      _videoController!.dispose().then((value) {
        videoInit();
      });
    }
  }

  Future<void> videoInit() async {
    currentPosition = const Duration();

    _videoController = VideoPlayerController.file(
      widget.file,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    await Future.wait([
      _videoController!.initialize(),
    ]);

    // slider 변경
    _videoController!.addListener(
      () {
        final currentPosition = _videoController!.value.position;
        if (mounted) {
          setState(() {
            this.currentPosition = currentPosition;
          });
        }
      },
    );

    _videoController!.addListener(videoListener);
    _videoController!.play();
    _videoController!.pause();
    if (mounted) {
      setState(() {});
    }
  }

  void videoListener() {}

  @override
  Widget build(BuildContext context) {
    if (_videoController == null || _videoController!.value.isBuffering) {
      return Container(
        color: Pallete.background,
        child: const Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
            backgroundColor: Pallete.background,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        isShowControlls = !isShowControlls;
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      // !_videoController!.value.isInitialized ||
                      //         _videoController!.value.isBuffering
                      // ? Container(
                      //     color: Pallete.background,
                      //     child: const Center(
                      //       child: CircularProgressIndicator(
                      //         color: Pallete.point,
                      //         backgroundColor: Colors.black,
                      //       ),
                      //     ),
                      //   )
                      // :
                      Hero(
                        tag: widget.file.path,
                        child: Container(
                          color: Pallete.background,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        ),
                      ),
                      if (isShowControlls)
                        _Controls(
                          onForwarPressed: onForwarPressed,
                          onPlayPressed: onPlayPressed,
                          onReversePressed: onReversePressed,
                          isPlaying: _videoController!.value.isPlaying,
                        ),
                      if (isShowControlls)
                        _Slider(
                          currentPosition: currentPosition,
                          maxPpsition: _videoController!.value.duration,
                          onSlideChanged: onSlideChanged,
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  FirebaseAnalytics.instance
                      .logEvent(name: 'click_video_crop_button');
                  _videoController!.pause();

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          VideoEditorScreen(
                        file: widget.file,
                        index: widget.index,
                        isComment: widget.isComment,
                        threadId: widget.threadId,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                icon: const Icon(
                  LineIcons.cut,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void onPlayPressed() {
    //실행중이면 정지
    //실행중이 아니면 실행
    if (mounted) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  void onForwarPressed() {
    final maxPosition = _videoController!.value.duration;
    final currentPosition = _videoController!.value.position;
    Duration position = const Duration();
    if ((maxPosition.inSeconds - const Duration(seconds: 5).inSeconds) >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 5);
    }

    _videoController!.seekTo(position);
  }

  void onReversePressed() {
    final currentPosition = _videoController!.value.position;
    Duration position = const Duration();
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - const Duration(seconds: 5);
    }

    _videoController!.seekTo(position);
  }

  void onSlideChanged(double value) {
    _videoController!.seekTo(Duration(seconds: value.toInt()));
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwarPressed;
  final bool isPlaying;

  const _Controls({
    required this.onPlayPressed,
    required this.onReversePressed,
    required this.onForwarPressed,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: 100.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
            onPressed: onReversePressed,
            iconData: Icons.keyboard_double_arrow_left_rounded,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwarPressed,
            iconData: Icons.keyboard_double_arrow_right_rounded,
          ),
        ],
      ),
    );
  }

  IconButton renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(iconData, color: Colors.white, size: 40.0),
    );
  }
}

class _Slider extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPpsition;
  final ValueChanged<double> onSlideChanged;

  const _Slider({
    required this.currentPosition,
    required this.maxPpsition,
    required this.onSlideChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: maxPpsition.inSeconds.toDouble(),
                value: currentPosition.inSeconds.toDouble(),
                thumbColor: Pallete.point,
                activeColor: Pallete.point.withOpacity(0.7),
                inactiveColor: Colors.white.withOpacity(0.7),
                onChanged: onSlideChanged,
              ),
            ),
            Text(
              '${maxPpsition.inMinutes}:${(maxPpsition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
