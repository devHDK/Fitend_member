import 'dart:io';

import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class GuideVideoPlayer extends StatefulWidget {
  final List<ExerciseVideo> videos;
  final bool isGuide;

  const GuideVideoPlayer({
    super.key,
    required this.videos,
    this.isGuide = true,
  });

  @override
  State<GuideVideoPlayer> createState() => _GuideVideoPlayerState();
}

class _GuideVideoPlayerState extends State<GuideVideoPlayer> {
  VideoPlayerController? firstVideoController;
  VideoPlayerController? secondVideoController;

  Duration currentPosition = const Duration();
  bool isShowControlls = true;
  List<bool> isPlaying = [true, false, false];
  double doubleSpeed = 1.0;

  @override
  void initState() {
    super.initState();

    firstVideoInit().then((value) {
      firstVideoController!.play();
    });

    if (widget.videos.length > 1) {
      secondVideoInit();
    }
  }

  @override
  void dispose() {
    firstVideoController!.removeListener(firstVideoListener);
    firstVideoController!.dispose();
    if (widget.videos.length > 1) {
      secondVideoController!.removeListener(secondVideoListener);
      secondVideoController!.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GuideVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videos[0].url != widget.videos[0].url) {
      firstVideoController!.removeListener(firstVideoListener);
      firstVideoController!.dispose().then((value) {
        firstVideoInit().then((value) {
          firstVideoController!.play();
        });
      });
    }
  }

  Future<void> firstVideoInit() async {
    currentPosition = const Duration();

    final file = await DefaultCacheManager()
        .getSingleFile(widget.videos[0].url, key: widget.videos[0].url);

    firstVideoController = VideoPlayerController.file(
      file,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    await Future.wait([
      firstVideoController!.initialize(),
    ]);

    await firstVideoController!.setLooping(true);
    await firstVideoController!.setVolume(0.0);

    // slider 변경

    firstVideoController!.addListener(firstVideoListener);

    if (mounted) {
      setState(() {});
    }
  }

  void firstVideoListener() {
    if (Platform.isAndroid &&
        firstVideoController!.value.duration > const Duration(seconds: 1) &&
        firstVideoController!.value.position >
            (firstVideoController!.value.duration -
                const Duration(milliseconds: 500)) &&
        firstVideoController!.value.isPlaying) {
      firstVideoController!.seekTo(const Duration(milliseconds: 100));
    }
  }

  Future<void> secondVideoInit() async {
    final file = await DefaultCacheManager()
        .getSingleFile(widget.videos[1].url, key: widget.videos[1].url);
    //2번째 영상
    secondVideoController = VideoPlayerController.file(
      file,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    await Future.wait([
      secondVideoController!.initialize(),
    ]);

    secondVideoController!.setLooping(true);
    secondVideoController!.setVolume(0.0);

    secondVideoController!.addListener(secondVideoListener);
  }

  void secondVideoListener() {
    if (Platform.isAndroid &&
        secondVideoController!.value.duration > const Duration(seconds: 1) &&
        secondVideoController!.value.position >
            (secondVideoController!.value.duration -
                const Duration(milliseconds: 500)) &&
        secondVideoController!.value.isPlaying) {
      secondVideoController!.seekTo(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstVideoController == null ||
        firstVideoController!.value.isBuffering) {
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

    return AspectRatio(
      aspectRatio: firstVideoController!.value.aspectRatio,
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
            AnimatedOpacity(
              opacity: isPlaying[0] ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: !firstVideoController!.value.isInitialized ||
                      firstVideoController!.value.isBuffering
                  ? Container(
                      color: Pallete.background,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Pallete.point,
                          backgroundColor: Pallete.background,
                        ),
                      ),
                    )
                  : Container(
                      color: Pallete.background,
                      child: VideoPlayer(firstVideoController!),
                    ),
            ),
            if ((widget.videos.length > 1 && secondVideoController != null) &&
                widget.isGuide)
              AnimatedOpacity(
                opacity: isPlaying[1] ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: widget.videos.length > 1 &&
                        secondVideoController!.value.isInitialized
                    ? Container(
                        color: Pallete.background,
                        child: VideoPlayer(secondVideoController!),
                      )
                    : Container(
                        color: Pallete.background,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Pallete.point,
                            backgroundColor: Pallete.background,
                          ),
                        ),
                      ),
              ),

            if (isShowControlls && widget.isGuide)
              Positioned(
                left: 28,
                bottom: 10,
                child: SizedBox(
                  height: 300,
                  width: 48,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.videos.length > 1 &&
                            secondVideoController != null)
                          GestureDetector(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  for (int i = 0; i < isPlaying.length; i++) {
                                    isPlaying[i] = false;
                                  }
                                  isPlaying[1] = true;
                                  firstVideoController!.pause();
                                  secondVideoController!.play();
                                });
                              }
                            },
                            child: Container(
                              height: 87,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isPlaying[1] ? Pallete.point : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: CustomNetworkImage(
                                  imageUrl: widget.videos[1].thumbnail,
                                  boxFit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (widget.videos.length > 1)
                          GestureDetector(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  for (int i = 0; i < isPlaying.length; i++) {
                                    isPlaying[i] = false;
                                  }
                                  isPlaying[0] = true;

                                  if (widget.videos.length > 1) {
                                    secondVideoController!.pause();
                                  }
                                  firstVideoController!.play();
                                });
                              }
                            },
                            child: Container(
                              height: 87,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isPlaying[0] ? Pallete.point : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: CustomNetworkImage(
                                  imageUrl: widget.videos[0].thumbnail,
                                  boxFit: BoxFit.fill,
                                ),
                              ),
                            ),
                          )
                      ]),
                ),
              ),

            if (isShowControlls && widget.isGuide) _videoSpeedControlButton()

            // if (showControlls)
            //   _Controls(
            //     onForwarPressed: onForwarPressed,
            //     onPlayPressed: onPlayPressed,
            //     onReversePressed: onReversePressed,
            //     isPlaying: videoController!.value.isPlaying,
            //   ),
            // if (showControlls)
            //   _Slider(
            //       currentPosition: currentPosition,
            //       maxPpsition: videoController!.value.duration,
            //       onSlideChanged: onSlideChanged)
          ],
        ),
      ),
    );
  }

  Positioned _videoSpeedControlButton() {
    return Positioned(
      right: 28,
      bottom: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Pallete.darkGray,
          ),
          onPressed: () {
            if (mounted) {
              setState(
                () {
                  if (doubleSpeed == 1.0) {
                    doubleSpeed = 0.5;
                  } else {
                    doubleSpeed = 1.0;
                  }

                  firstVideoController!.setPlaybackSpeed(doubleSpeed);

                  if (widget.videos.length > 1) {
                    secondVideoController!.setPlaybackSpeed(doubleSpeed);
                  }
                },
              );
            }
          },
          child: Text(
            'X $doubleSpeed',
            style: s3SubTitle,
          ),
        ),
      ),
    );
  }

  void onPlayPressed() {
    //실행중이면 정지
    //실행중이 아니면 실행
    if (mounted) {
      setState(() {
        if (firstVideoController!.value.isPlaying) {
          firstVideoController!.pause();
        } else {
          firstVideoController!.play();
        }
      });
    }
  }

  void onForwarPressed() {
    final maxPosition = firstVideoController!.value.duration;
    final currentPosition = firstVideoController!.value.position;
    Duration position = const Duration();
    if ((maxPosition.inSeconds - const Duration(seconds: 3).inSeconds) >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 3);
    }

    firstVideoController!.seekTo(position);
  }

  void onReversePressed() {
    final currentPosition = firstVideoController!.value.position;
    Duration position = const Duration();
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - const Duration(seconds: 3);
    }

    firstVideoController!.seekTo(position);
  }

  void onSlideChanged(double value) {
    firstVideoController!.seekTo(Duration(seconds: value.toInt()));
  }
}

// class _Controls extends StatelessWidget {
//   final VoidCallback onPlayPressed;
//   final VoidCallback onReversePressed;
//   final VoidCallback onForwarPressed;
//   final bool isPlaying;

//   const _Controls({
//     required this.onPlayPressed,
//     required this.onReversePressed,
//     required this.onForwarPressed,
//     required this.isPlaying,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black.withOpacity(0.5),
//       height: 100.h,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           renderIconButton(
//             onPressed: onReversePressed,
//             iconData: Icons.keyboard_double_arrow_left_rounded,
//           ),
//           renderIconButton(
//             onPressed: onPlayPressed,
//             iconData: isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//           renderIconButton(
//             onPressed: onForwarPressed,
//             iconData: Icons.keyboard_double_arrow_right_rounded,
//           ),
//         ],
//       ),
//     );
//   }

//   IconButton renderIconButton({
//     required VoidCallback onPressed,
//     required IconData iconData,
//   }) {
//     return IconButton(
//       onPressed: onPressed,
//       icon: Icon(iconData, color: Colors.white, size: 40.0),
//     );
//   }
// }

// class _Slider extends StatelessWidget {
//   final Duration currentPosition;
//   final Duration maxPpsition;
//   final ValueChanged<double> onSlideChanged;

//   const _Slider({
//     required this.currentPosition,
//     required this.maxPpsition,
//     required this.onSlideChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: 0,
//       right: 0,
//       left: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0),
//         child: Row(
//           children: [
//             Text(
//               '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
//               style: const TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//             Expanded(
//               child: Slider(
//                 min: 0,
//                 max: maxPpsition.inSeconds.toDouble(),
//                 value: currentPosition.inSeconds.toDouble(),
//                 onChanged: onSlideChanged,
//               ),
//             ),
//             Text(
//               '${maxPpsition.inMinutes}:${(maxPpsition.inSeconds % 60).toString().padLeft(2, '0')}',
//               style: const TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
