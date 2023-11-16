import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoPlayer extends ConsumerStatefulWidget {
  const NetworkVideoPlayer({
    super.key,
    required this.video,
  });

  final GalleryModel video;

  @override
  ConsumerState<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends ConsumerState<NetworkVideoPlayer> {
  VideoPlayerController? _videoController;

  Duration currentPosition = const Duration();
  bool isShowControlls = false;
  bool isPlaying = false;
  double volume = 50.0;
  bool mute = true;

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
  void didUpdateWidget(covariant NetworkVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video != widget.video) {
      _videoController!.removeListener(videoListener);
      _videoController!.dispose().then((value) {
        videoInit();
      });
    }
  }

  Future<void> videoInit() async {
    currentPosition = const Duration();

    final file = await DefaultCacheManager().getSingleFile(
        '$s3Url${widget.video.url}',
        key: '$s3Url${widget.video.url}');

    _videoController = VideoPlayerController.file(
      file,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    await Future.wait([
      _videoController!.initialize(),
    ]).then((value) {
      _videoController!.play();
      _videoController!.setVolume(0);
      // if (Platform.isAndroid) {
      //   _videoController!.pause();
      // }
    });

    // slider 변경
    _videoController!.addListener(
      () {
        final currentPosition = _videoController!.value.position;
        setState(() {
          this.currentPosition = currentPosition;
        });
      },
    );

    _videoController!.addListener(videoListener);

    setState(() {});
  }

  void videoListener() {}

  @override
  Widget build(BuildContext context) {
    if (_videoController == null) {
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
                    setState(() {
                      isShowControlls = !isShowControlls;
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        color: Pallete.background,
                        child: Center(
                          child: VideoPlayer(_videoController!),
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
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                mute = !mute;
                              });

                              if (mute) {
                                _videoController!.setVolume(0);
                              } else {
                                _videoController!.setVolume(volume);
                              }
                            },
                            icon: Icon(
                              mute ? Icons.volume_off : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
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
      ],
    );
  }

  void onPlayPressed() {
    //실행중이면 정지
    //실행중이 아니면 실행
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
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
