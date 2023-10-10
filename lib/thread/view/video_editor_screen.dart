import 'dart:io';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/video_crop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditorScreen extends ConsumerStatefulWidget {
  const VideoEditorScreen({
    super.key,
    required this.file,
    required this.index,
    this.parentUpdate,
  });

  final File file;
  final int index;
  final Function? parentUpdate;

  @override
  ConsumerState<VideoEditorScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends ConsumerState<VideoEditorScreen> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool isLoading = false;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 180),
  );

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) => setState(() {})).catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    MediaUtils.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo(ThreadCreateTempModel state, int index) async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    setState(() {
      isLoading = true;
    });

    await MediaUtils.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
      },
      onError: (e, s) => _showErrorSnackBar("Error on export video :("),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;

        if (widget.parentUpdate != null) {
          widget.parentUpdate!();
        }

        setState(() {
          ref.read(threadCreateProvider.notifier).changeAsset(index, file.path);
        });
      },
    ).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  // void _exportCover() async {
  //   final config = CoverFFmpegVideoEditorConfig(_controller);
  //   final execute = await config.getExecuteConfig();
  //   if (execute == null) {
  //     _showErrorSnackBar("Error on cover exportation initialization.");
  //     return;
  //   }

  //   await MediaUtils.runFFmpegCommand(
  //     execute,
  //     onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
  //     onCompleted: (cover) {
  //       if (!mounted) return;

  //       showDialog(
  //         context: context,
  //         builder: (_) => CoverResultPopup(cover: cover),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadCreateProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CropGridViewer.preview(controller: _controller),
                              AnimatedBuilder(
                                animation: _controller.video,
                                builder: (_, __) => AnimatedOpacity(
                                  opacity: _controller.isPlaying ? 0 : 1,
                                  duration: kThemeAnimationDuration,
                                  child: GestureDetector(
                                    onTap: _controller.video.play,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100.w,
                          child: Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _trimSlider(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _bottomNavBar(state, widget.index),
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _bottomNavBar(ThreadCreateTempModel state, int index) {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  '취소',
                  style: h5Headline.copyWith(
                    color: const Color(0xff0474f1),
                    height: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(
                  Icons.rotate_left,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          VideoCropScreen(controller: _controller),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    )),
                icon: const Icon(
                  Icons.crop,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(
                  Icons.rotate_right,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  _exportVideo(state, index);

                  context.pop();
                },
                child: Text(
                  '저장',
                  style: h5Headline.copyWith(
                    color: const Color(0xffffcc00),
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(
              children: [
                Text(
                  formatter(Duration(seconds: pos.toInt())),
                  style: s3SubTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Expanded(child: SizedBox()),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatter(_controller.startTrim),
                      style: s3SubTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatter(_controller.endTrim),
                      style: s3SubTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      Container(
        width: 100.w,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          hasHaptic: true,
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
            textStyle: s3SubTitle.copyWith(color: Colors.white),
          ),
        ),
      )
    ];
  }
}
