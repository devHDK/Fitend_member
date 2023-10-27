import 'dart:io';

import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NetworkVideoPlayerMini extends ConsumerStatefulWidget {
  const NetworkVideoPlayerMini({
    super.key,
    required this.video,
    this.userOriginRatio = false,
  });

  final GalleryModel video;
  final bool? userOriginRatio;

  @override
  ConsumerState<NetworkVideoPlayerMini> createState() =>
      _EditVideoPlayerState();
}

class _EditVideoPlayerState extends ConsumerState<NetworkVideoPlayerMini> {
  VideoPlayerController? _videoController;

  Duration currentPosition = const Duration();
  bool isPlaying = false;
  bool videoDisposed = true;

  @override
  void initState() {
    super.initState();

    // videoInit();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPlayerMini oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video != widget.video) {
      if (_videoController != null) {
        _videoController!.dispose().then((value) {
          videoInit();
        });
      }
    }
  }

  Future<void> videoInit() async {
    // print('video init! $s3Url${widget.video.url} ');

    currentPosition = const Duration();
    File? file;
    final fileInfo = await DefaultCacheManager()
        .getFileFromCache('$s3Url${widget.video.url}');

    if (fileInfo != null) {
      file = fileInfo.file;
    } else {
      debugPrint('video download...');
      file = await DefaultCacheManager().getSingleFile(
          '$s3Url${widget.video.url}',
          key: '$s3Url${widget.video.url}');
    }

    _videoController = VideoPlayerController.file(
      file,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    await Future.wait([
      _videoController!.initialize(),
    ]).then((value) {
      _videoController!.setVolume(0);
      // _videoController!.setLooping(true);
      // _videoController!.play();

      _videoController!.addListener(() {
        if (_videoController!.value.isPlaying) return;

        if (_videoController!.value.position >=
            _videoController!.value.duration) {
          // loop
          _videoController!.seekTo(const Duration(seconds: 0));
          _videoController!.play();
        }
      });

      // if (Platform.isAndroid) {
      //   _videoController!.pause();
      // }
    });

    videoDisposed = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null ||
        videoDisposed ||
        _videoController!.value.isBuffering ||
        !_videoController!.value.isInitialized) {
      return VisibilityDetector(
        key: ValueKey('$s3Url${widget.video.url}_1'),
        onVisibilityChanged: (info) {
          var visiblePercentage = info.visibleFraction * 100;

          if (visiblePercentage > 60) {
            videoInit().then((value) {
              setState(() {
                videoDisposed = false;
              });
            });
          }
        },
        child: Container(
          // width: 100.w - 110,
          color: Colors.black26,
          child: CustomNetworkImage(
            imageUrl: '$s3Url${widget.video.thumbnail}',
            boxFit: BoxFit.fitWidth,
          ),
        ),
      );
    } else {
      return VisibilityDetector(
        key: ValueKey('$s3Url${widget.video.url}'),
        onVisibilityChanged: (info) {
          var visiblePercentage = info.visibleFraction * 100;

          if (visiblePercentage < 20) {
            _videoController?.pause();
            _videoController?.dispose();
            _videoController = null;
            setState(() {
              videoDisposed = true;
            });
          }

          if (visiblePercentage > 60) {
            _videoController?.play();
          }
        },
        child: Container(
          color: Colors.black26,
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.userOriginRatio! && _videoController != null
                  ? _videoController!.value.aspectRatio
                  : 1 / 0.8,
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Stack(
                    children: [
                      VideoPlayer(
                        _videoController!,
                        // key: ValueKey('$s3Url${widget.video.url}'),
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
              ),
            ),
          ),
        ),
      );
    }
  }
}
