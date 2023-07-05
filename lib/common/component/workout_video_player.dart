import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class WorkoutVideoPlayer extends StatefulWidget {
  final ExerciseVideo video;

  const WorkoutVideoPlayer({
    super.key,
    required this.video,
  });

  @override
  State<WorkoutVideoPlayer> createState() => _WorkoutVideoPlayerState();
}

class _WorkoutVideoPlayerState extends State<WorkoutVideoPlayer> {
  VideoPlayerController? videoController;

  Duration currentPosition = const Duration();
  bool isShowControlls = false;

  @override
  void initState() {
    super.initState();
    videoInit();

    videoController!.setVolume(0);
    videoController!.play();
  }

  @override
  void dispose() {
    if (mounted) {
      videoController!.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WorkoutVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video.url != widget.video.url) {
      videoInit();
      videoController!.setVolume(0);
      videoController!.play();
    }
  }

  void videoInit() async {
    currentPosition = const Duration();
    videoController = VideoPlayerController.network(
      widget.video.url,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    await Future.wait([
      videoController!.initialize(),
    ]);

    // slider 변경
    videoController!.addListener(
      () {
        final currentPosition = videoController!.value.position;
        setState(() {
          this.currentPosition = currentPosition;
        });
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: videoController!.value.aspectRatio,
      child: Stack(
        children: [
          videoController!.value.isPlaying
              ? VideoPlayer(videoController!)
              : SizedBox(
                  height: MediaQuery.of(context).size.height - 175,
                  child: CustomNetworkImage(
                    imageUrl: widget.video.thumbnail,
                    boxFit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height - 175,
                  ),
                ),

          if (!videoController!.value.isPlaying)
            _Controls(
              onForwarPressed: onForwarPressed,
              onPlayPressed: onPlayPressed,
              onReversePressed: onReversePressed,
              isPlaying: videoController!.value.isPlaying,
            ),
          // if (showControlls)
          //   _Slider(
          //       currentPosition: currentPosition,
          //       maxPpsition: videoController!.value.duration,
          //       onSlideChanged: onSlideChanged)
        ],
      ),
    );
  }

  void onPlayPressed() {
    //실행중이면 정지
    //실행중이 아니면 실행
    setState(() {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    });
  }

  void onForwarPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;
    Duration position = const Duration();
    if ((maxPosition.inSeconds - const Duration(seconds: 3).inSeconds) >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;
    Duration position = const Duration();
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - const Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onSlideChanged(double value) {
    videoController!.seekTo(Duration(seconds: value.toInt()));
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
      color: Colors.black.withOpacity(0.3),
      height: MediaQuery.of(context).size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // renderIconButton(
          //   onPressed: onReversePressed,
          //   iconData: Icons.rotate_left,
          // ),
          // renderIconButton(
          //   onPressed: onPlayPressed,
          //   iconData: isPlaying ? Icons.pause : Icons.play_circle_fill_sharp,
          // ),
          GestureDetector(
            onTap: onPlayPressed,
            child: SvgPicture.asset('asset/img/icon_play.svg'),
          )
          // renderIconButton(
          //   onPressed: onForwarPressed,
          //   iconData: Icons.rotate_right,
          // ),
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
      icon: Icon(
        iconData,
        color: Colors.black,
        size: 64.0,
      ),
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
