import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraAwesomeScreen extends ConsumerStatefulWidget {
  const CameraAwesomeScreen({
    super.key,
    required this.diretoryPath,
  });

  final String diretoryPath;

  @override
  ConsumerState<CameraAwesomeScreen> createState() =>
      _CustomCameraScreenState();
}

class _CustomCameraScreenState extends ConsumerState<CameraAwesomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); //뒤로가기
          },
          icon: const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Icon(Icons.close_sharp),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body:

          // CameraAwesomeBuilder.custom(
          //   builder: (state, previewSize, previewRect) {
          //     return state.when(
          //       onPreparingCamera: (state) => const Center(
          //           child: CircularProgressIndicator(
          //         color: POINT_COLOR,
          //       )),
          //       onPhotoMode: (state) => TakePhotoUI(state),
          //       onVideoMode: (state) => RecordVideoUI(state, recording: false),
          //       onVideoRecordingMode: (state) =>
          //           RecordVideoUI(state, recording: true),
          //     );
          //   },
          //   saveConfig: SaveConfig.photoAndVideo(
          //     photoPathBuilder: () {
          //       final String filePath =
          //           '${widget.diretoryPath}/fitend_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

          //       return Future.value(filePath);
          //     },
          //     videoPathBuilder: () {
          //       final String filePath =
          //           '${widget.diretoryPath}/fitend_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

          //       return Future.value(filePath);
          //     },
          //     initialCaptureMode: CaptureMode.photo,
          //   ),
          // )

          CameraAwesomeBuilder.awesome(
        sensor: Sensors.back,
        aspectRatio: CameraAspectRatios.ratio_16_9,
        enableAudio: true,
        saveConfig: SaveConfig.photoAndVideo(
          photoPathBuilder: () {
            final String filePath =
                '${widget.diretoryPath}/fitend_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

            print('filePath : $filePath');

            return Future.value(filePath);
          },
          videoPathBuilder: () {
            final String filePath =
                '${widget.diretoryPath}/fitend_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

            return Future.value(filePath);
          },
          initialCaptureMode: CaptureMode.photo,
        ),
        previewFit: CameraPreviewFit.contain,
        theme: AwesomeTheme(
          buttonTheme: AwesomeButtonTheme(
            iconSize: 15,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            buttonBuilder: (child, onTap) {
              return ClipOval(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onTap,
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
        onMediaTap: (p0) async {
          await ref
              .read(threadCreateProvider.notifier)
              .pickImage(context)
              .then((assets) async {
            if (assets != null && assets.isNotEmpty) {
              ref.read(threadCreateProvider.notifier).updateIsLoading(true);

              for (var asset in assets) {
                if (await asset.file != null) {
                  final file = await asset.file;

                  ref.read(threadCreateProvider.notifier).addAssets(file!.path);

                  print('file.path : ${file.path}');
                }
              }

              ref.read(threadCreateProvider.notifier).updateIsLoading(false);
            } else {
              print('assets: $assets');
            }
          });
        },
        exifPreferences: ExifPreferences(saveGPSLocation: true),
      ),
    );
  }
}

class TakePhotoUI extends StatelessWidget {
  final PhotoCameraState state;

  const TakePhotoUI(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RecordVideoUI extends StatelessWidget {
  final CameraState state;
  final bool recording;

  const RecordVideoUI(this.state, {super.key, required this.recording});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
