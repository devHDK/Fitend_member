import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String firstUrl;
  final String secondUrl;

  const CustomVideoPlayer({
    super.key,
    required this.firstUrl,
    required this.secondUrl,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? firstVideoController;
  VideoPlayerController? secondVideoController;
  Duration currentPosition = const Duration();
  bool showControlls = false;
  bool isPlayingFirstUrl = true;
  double doubleSpeed = 1.0;

  @override
  void initState() {
    super.initState();

    initializeController();
    firstVideoController!.play();
  }

  @override
  void dispose() {
    firstVideoController!.dispose();
    secondVideoController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.firstUrl != widget.firstUrl) {
      initializeController();
    }
  }

  void initializeController() async {
    currentPosition = const Duration();
    firstVideoController = VideoPlayerController.network(
      widget.firstUrl,
    );
    secondVideoController = VideoPlayerController.network(
      widget.secondUrl,
    );

    await Future.wait([
      firstVideoController!.initialize(),
      secondVideoController!.initialize(),
    ]);

    firstVideoController!.setLooping(true);
    secondVideoController!.setLooping(true);

    firstVideoController!.setVolume(0.0);
    secondVideoController!.setVolume(0.0);

    // slider 변경
    firstVideoController!.addListener(
      () {
        final currentPosition = firstVideoController!.value.position;
        setState(() {
          this.currentPosition = currentPosition;
        });
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (firstVideoController == null) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: firstVideoController!.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showControlls = !showControlls;
          });
        },
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: isPlayingFirstUrl ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: VideoPlayer(
                firstVideoController!,
              ),
            ),
            AnimatedOpacity(
              opacity: !isPlayingFirstUrl ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: VideoPlayer(
                secondVideoController!,
              ),
            ),
            if (showControlls)
              Positioned(
                left: 28,
                bottom: 10,
                child: SizedBox(
                  height: 190,
                  width: 48,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPlayingFirstUrl = true;
                            secondVideoController!.pause();
                            firstVideoController!.play();
                            print(
                                'first video: ${firstVideoController!.value.isPlaying}');
                          });
                        },
                        child: Container(
                            height: 85,
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isPlayingFirstUrl ? POINT_COLOR : null,
                            ),
                            child: const Placeholder(
                              color: POINT_COLOR,
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPlayingFirstUrl = false;
                            firstVideoController!.pause();
                            secondVideoController!.play();
                          });
                          print(
                              'second video: ${secondVideoController!.value.isPlaying}');
                        },
                        child: Container(
                            height: 85,
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: !isPlayingFirstUrl ? POINT_COLOR : null,
                            ),
                            child: const Placeholder(
                              color: POINT_COLOR,
                            )),
                      ),
                    ],
                  ),
                ),
              ),

            if (showControlls)
              Positioned(
                right: 28,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DARK_GRAY_COLOR,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          if (doubleSpeed == 1.0) {
                            doubleSpeed = 0.5;
                          } else if (doubleSpeed == 0.5) {
                            doubleSpeed = 2.0;
                          } else if (doubleSpeed == 2.0) {
                            doubleSpeed = 1.0;
                          }
                          firstVideoController!.setPlaybackSpeed(doubleSpeed);
                          secondVideoController!.setPlaybackSpeed(doubleSpeed);
                        },
                      );
                    },
                    child: Text(
                      'X $doubleSpeed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              )

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

  void onPlayPressed() {
    //실행중이면 정지
    //실행중이 아니면 실행
    setState(() {
      if (firstVideoController!.value.isPlaying) {
        firstVideoController!.pause();
      } else {
        firstVideoController!.play();
      }
    });
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
      height: MediaQuery.of(context).size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
            onPressed: onReversePressed,
            iconData: Icons.rotate_left,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwarPressed,
            iconData: Icons.rotate_right,
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
