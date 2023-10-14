import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoPlayerMini extends ConsumerStatefulWidget {
  const NetworkVideoPlayerMini({
    super.key,
    required this.video,
  });

  final GalleryModel video;

  @override
  ConsumerState<NetworkVideoPlayerMini> createState() =>
      _EditVideoPlayerState();
}

class _EditVideoPlayerState extends ConsumerState<NetworkVideoPlayerMini> {
  VideoPlayerController? _videoController;

  Duration currentPosition = const Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    videoInit();
  }

  @override
  void dispose() {
    _videoController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPlayerMini oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video != widget.video) {
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
    ]);

    _videoController!.setVolume(0);
    _videoController!.setLooping(true);
    _videoController!.play();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null || _videoController!.value.isBuffering) {
      return Container(
        color: BACKGROUND_COLOR,
        child: const Center(
          child: CircularProgressIndicator(
            color: POINT_COLOR,
            backgroundColor: BACKGROUND_COLOR,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Stack(
            children: [
              SizedBox(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / 0.8,
                    child: Container(
                      color: BACKGROUND_COLOR,
                      child: Center(
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      DataUtils.getTimeStringMinutes(
                        _videoController!.value.duration.inSeconds,
                      ).toString(),
                      style: s3SubTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
