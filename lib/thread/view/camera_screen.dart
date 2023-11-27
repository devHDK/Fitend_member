import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/avail_camera_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/provider/comment_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_camera_sound/native_camera_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({
    super.key,
    this.isComment = false,
    this.threadId,
  });
  final bool? isComment;
  final int? threadId;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;

  List<CameraDescription> cameras = [];
  int orientation = 0;

  late Timer timer;
  int recordingDuration = 0;
  int takedAssetsCount = 0;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.veryHigh;

  void recordingTimerStart() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
  }

  void recordingTimerStop() {
    timer.cancel();
  }

  void onTick(Timer timer) {
    if (mounted) {
      setState(() {
        recordingDuration++;
      });
    }
  }

  getPermissionStatus() async {
    PermissionStatus status = await Permission.camera.request();

    // if (status.isDenied) {
    //   await Permission.camera.request();

    //   status = await Permission.camera.status;
    // }

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      getAvailableCameras();

      if (mounted) {
        setState(() {
          _isCameraPermissionGranted = true;
        });
      }
    } else {
      log('Camera Permission: DENIED');
    }
  }

  void getAvailableCameras() async {
    try {
      AsyncValue<List<CameraDescription>> camerasAsyncValue =
          ref.read(availableCamerasProvider);

      camerasAsyncValue.whenData((value) {
        cameras = value;
      });

      onNewCameraSelected(cameras[0]);
    } on CameraException catch (e) {
      debugPrint('Error in fetching the cameras: $e');
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      // cameraController.setFlashMode(FlashMode.auto);
      cameraController.setFlashMode(FlashMode.off);

      XFile file = await cameraController.takePicture();

      if (Platform.isAndroid) {
        NativeCameraSound.playShutter();
      }

      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      if (mounted) {
        setState(() {
          NativeCameraSound.playStartRecord();
          _isRecordingInProgress = true;
          recordingTimerStart();
        });
      }
    } on CameraException catch (e) {
      debugPrint('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      if (mounted) {
        setState(() {
          NativeCameraSound.playStopRecord();
          _isRecordingInProgress = false;
          recordingTimerStop();
          recordingDuration = 0;
        });
      }
      return file;
    } on CameraException catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
      recordingTimerStop();
    } on CameraException catch (e) {
      debugPrint('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
      recordingTimerStart();
    } on CameraException catch (e) {
      debugPrint('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
      controller!.setFlashMode(FlashMode.off);
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController.getMaxZoomLevel().then((value) {
          if (value > 15.0) {
            _maxAvailableZoom = 15.0;
          } else {
            _maxAvailableZoom = value;
          }
        }),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    getPermissionStatus();

    WakelockPlus.enable();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (_isRecordingInProgress) {
        XFile? rawVideo = await stopVideoRecording();
        File videoFile = File(rawVideo!.path);

        await ImageGallerySaver.saveFile(
          videoFile.path,
        );
        if (mounted) {
          setState(() {
            takedAssetsCount++;
          });
        }
      }

      await cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    controller?.dispose();

    if (timer.isActive) {
      timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 40,
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
        body: _isCameraPermissionGranted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w * 16 / 9,
                    child: AspectRatio(
                      aspectRatio: _isCameraInitialized
                          ? controller!.value.aspectRatio
                          : 9 / 16,
                      child: Stack(
                        children: [
                          _isCameraInitialized
                              ? RotatedBox(
                                  quarterTurns: controller!
                                              .value.deviceOrientation ==
                                          DeviceOrientation.landscapeRight
                                      ? 1
                                      : controller!.value.deviceOrientation ==
                                              DeviceOrientation.landscapeLeft
                                          ? 3
                                          : controller!.value
                                                      .deviceOrientation ==
                                                  DeviceOrientation.portraitUp
                                              ? 0
                                              : 2,
                                  child: CameraPreview(
                                    controller!,
                                    child: LayoutBuilder(builder: (
                                      BuildContext context,
                                      BoxConstraints constraints,
                                    ) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTapDown: (details) => onViewFinderTap(
                                            details, constraints),
                                      );
                                    }),
                                  ),
                                )
                              : Container(
                                  color: Colors.black,
                                ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Spacer(),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: _zoomSlider(),
                              //     ),
                              //     Padding(
                              //       padding:
                              //           const EdgeInsets.only(right: 8.0),
                              //       child: Container(
                              //         decoration: BoxDecoration(
                              //           color: Colors.black45,
                              //           borderRadius:
                              //               BorderRadius.circular(10.0),
                              //         ),
                              //         child: Padding(
                              //           padding: const EdgeInsets.all(5.0),
                              //           child: Text(
                              //             '${_currentZoomLevel.toStringAsFixed(1)}x',
                              //             style: const TextStyle(
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              if (_isRecordingInProgress ||
                                  recordingDuration > 0)
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.black38,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 5, 9, 5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Center(
                                            child: Text(
                                              DataUtils.getTimeStringMinutes(
                                                  recordingDuration),
                                              style: s1SubTitle.copyWith(
                                                color: Colors.white,
                                                fontSize: 18,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(
                                height: 11,
                              ),

                              Container(
                                color: Colors.black38,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 10),
                                  child: Column(
                                    children: [
                                      _isRecordingInProgress
                                          ? const SizedBox(
                                              height: 30,
                                            )
                                          : SizedBox(
                                              height: 30,
                                              child: ToggleSwitch(
                                                initialLabelIndex:
                                                    _isVideoCameraSelected
                                                        ? 1
                                                        : 0,
                                                totalSwitches: 2,
                                                activeBgColor: [
                                                  Pallete.point
                                                      .withOpacity(0.7),
                                                  Pallete.point
                                                      .withOpacity(0.7),
                                                ],
                                                customTextStyles: [
                                                  h6Headline.copyWith(
                                                      color: Colors.white,
                                                      height: 1),
                                                  h6Headline.copyWith(
                                                    color: Colors.white,
                                                    height: 1,
                                                  ),
                                                ],
                                                animate: true,
                                                animationDuration: 200,
                                                labels: const [
                                                  'PHOTO',
                                                  'VIDEO',
                                                ],
                                                onToggle: (index) {
                                                  if (index == 0) {
                                                    _isVideoCameraSelected =
                                                        false;
                                                  } else {
                                                    _isVideoCameraSelected =
                                                        true;
                                                  }
                                                  if (mounted) {
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                            ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: _isRecordingInProgress
                                                ? () async {
                                                    if (controller!.value
                                                        .isRecordingPaused) {
                                                      await resumeVideoRecording();
                                                    } else {
                                                      await pauseVideoRecording();
                                                    }
                                                  }
                                                : () {
                                                    if (mounted) {
                                                      setState(() {
                                                        _isCameraInitialized =
                                                            false;
                                                      });
                                                    }
                                                    onNewCameraSelected(cameras[
                                                        _isRearCameraSelected
                                                            ? 1
                                                            : 0]);
                                                    if (mounted) {
                                                      setState(() {
                                                        _isRearCameraSelected =
                                                            !_isRearCameraSelected;
                                                      });
                                                    }
                                                  },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.circle,
                                                  color: Colors.black38,
                                                  size: 50,
                                                ),
                                                _isRecordingInProgress
                                                    ? controller!.value
                                                            .isRecordingPaused
                                                        ? const Icon(
                                                            Icons.play_arrow,
                                                            color: Colors.white,
                                                            size: 25,
                                                          )
                                                        : const Icon(
                                                            Icons.pause,
                                                            color: Colors.white,
                                                            size: 25,
                                                          )
                                                    : const Icon(
                                                        Icons
                                                            .cameraswitch_outlined,
                                                        color: Colors.white,
                                                        size: 25,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: _isVideoCameraSelected
                                                ? () async {
                                                    if (_isRecordingInProgress) {
                                                      XFile? rawVideo =
                                                          await stopVideoRecording();
                                                      File videoFile =
                                                          File(rawVideo!.path);

                                                      await ImageGallerySaver
                                                          .saveFile(
                                                        videoFile.path,
                                                      );
                                                      if (mounted) {
                                                        setState(() {
                                                          takedAssetsCount++;
                                                        });
                                                      }
                                                    } else {
                                                      await startVideoRecording();
                                                    }
                                                  }
                                                : () async {
                                                    XFile? rawImage =
                                                        await takePicture();

                                                    if (rawImage != null) {
                                                      File imageFile =
                                                          File(rawImage.path);

                                                      await ImageGallerySaver
                                                          .saveFile(
                                                        imageFile.path,
                                                        isReturnPathOfIOS: true,
                                                      );
                                                      if (mounted) {
                                                        setState(() {
                                                          takedAssetsCount++;
                                                        });
                                                      }
                                                    } else {
                                                      debugPrint('save fail');
                                                    }
                                                  },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  color: _isVideoCameraSelected
                                                      ? Colors.white
                                                      : Colors.white38,
                                                  size: 80,
                                                ),
                                                Icon(
                                                  Icons.circle,
                                                  color: _isVideoCameraSelected
                                                      ? Colors.red
                                                      : Colors.white,
                                                  size: 65,
                                                ),
                                                _isVideoCameraSelected &&
                                                        _isRecordingInProgress
                                                    ? const Icon(
                                                        Icons.stop_rounded,
                                                        color: Colors.white,
                                                        size: 32,
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          if (!_isRecordingInProgress)
                                            _pickImage(
                                              context,
                                              widget.isComment!,
                                              widget.threadId,
                                              takedAssetsCount,
                                            )
                                          else
                                            const SizedBox(
                                              width: 50,
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Column(
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.only(top: 8.0),
                  //         child: Row(
                  //           children: [
                  //             Expanded(
                  //               child: Padding(
                  //                 padding: const EdgeInsets.only(
                  //                   left: 8.0,
                  //                   right: 4.0,
                  //                 ),
                  //                 child: TextButton(
                  //                   onPressed: _isRecordingInProgress
                  //                       ? null
                  //                       : () {
                  //                           if (_isVideoCameraSelected) {
                  //                             setState(() {
                  //                               _isVideoCameraSelected = false;
                  //                             });
                  //                           }
                  //                         },
                  //                   style: TextButton.styleFrom(
                  //                     foregroundColor: _isVideoCameraSelected
                  //                         ? Colors.black54
                  //                         : Colors.black,
                  //                     backgroundColor: _isVideoCameraSelected
                  //                         ? Colors.white30
                  //                         : Colors.white,
                  //                   ),
                  //                   child: const Text('IMAGE'),
                  //                 ),
                  //               ),
                  //             ),
                  //             Expanded(
                  //               child: Padding(
                  //                 padding: const EdgeInsets.only(
                  //                     left: 4.0, right: 8.0),
                  //                 child: TextButton(
                  //                   onPressed: () {
                  //                     if (!_isVideoCameraSelected) {
                  //                       setState(() {
                  //                         _isVideoCameraSelected = true;
                  //                       });
                  //                     }
                  //                   },
                  //                   style: TextButton.styleFrom(
                  //                     foregroundColor: _isVideoCameraSelected
                  //                         ? Colors.black
                  //                         : Colors.black54,
                  //                     backgroundColor: _isVideoCameraSelected
                  //                         ? Colors.white
                  //                         : Colors.white30,
                  //                   ),
                  //                   child: const Text('VIDEO'),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(),
                  Text(
                    '카메라 권한을 허용해주세요!',
                    style: h5Headline.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.point,
                      foregroundColor: Pallete.point,
                    ),
                    onPressed: () {
                      context.pop();
                      openAppSettings();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '📷 설정으로 이동',
                        style: h6Headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  InkWell _pickImage(
      BuildContext context, bool isComment, int? threadId, int count) {
    return InkWell(
      onTap: isComment && threadId != null
          ? () async {
              final model = ref.read(commentCreateProvider(threadId));

              if (model.assetsPaths.length < 10) {
                await ref
                    .read(commentCreateProvider(threadId).notifier)
                    .pickImage(context, 10 - model.assetsPaths.length)
                    .then(
                  (assets) async {
                    if (assets != null && assets.isNotEmpty) {
                      ref
                          .read(commentCreateProvider(threadId).notifier)
                          .updateIsLoading(true);

                      for (var asset in assets) {
                        if (await asset.file != null) {
                          final file = await asset.file;

                          ref
                              .read(commentCreateProvider(threadId).notifier)
                              .addAssets(file!.path);

                          debugPrint('file.path : ${file.path}');
                        }
                      }

                      ref
                          .read(commentCreateProvider(threadId).notifier)
                          .updateIsLoading(false);

                      if (!context.mounted) return;
                      context.pop();
                    } else {
                      debugPrint('assets: $assets');
                    }
                  },
                );
              } else {
                DialogWidgets.showToast('사진 또는 영상은 10개까지만 첨부할수있습니다!');
              }
            }
          : () async {
              final model = ref.read(threadCreateProvider);

              if (model.assetsPaths!.length < 10) {
                await ref
                    .read(threadCreateProvider.notifier)
                    .pickImage(context, 10 - model.assetsPaths!.length)
                    .then((assets) async {
                  if (assets != null && assets.isNotEmpty) {
                    ref
                        .read(threadCreateProvider.notifier)
                        .updateIsLoading(true);

                    for (var asset in assets) {
                      if (await asset.file != null) {
                        final file = await asset.file;

                        ref
                            .read(threadCreateProvider.notifier)
                            .addAssets(file!.path);

                        debugPrint('file.path : ${file.path}');
                      }
                    }

                    ref
                        .read(threadCreateProvider.notifier)
                        .updateIsLoading(false);
                    if (!context.mounted) return;
                    context.pop();
                  } else {
                    debugPrint('assets: $assets');
                  }
                });
              } else {
                DialogWidgets.showToast('사진 또는 영상은 10개까지만 첨부할수있습니다!');
              }
            },
      child: Stack(
        children: [
          Badge(
            label: Text(
              count.toString(),
            ),
            isLabelVisible: count > 0,
            child: const Icon(
              Icons.square_rounded,
              size: 50,
              color: Colors.black38,
            ),
          ),
          const Positioned(
            top: 10,
            left: 10,
            child: Icon(
              Icons.photo,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Slider _zoomSlider() {
    return Slider(
      value: _currentZoomLevel,
      min: _minAvailableZoom,
      max: _maxAvailableZoom,
      activeColor: Pallete.point.withOpacity(0.5),
      inactiveColor: Colors.white30,
      onChanged: (value) async {
        if (mounted) {
          setState(() {
            _currentZoomLevel = value;
          });
        }
        await controller!.setZoomLevel(value);
      },
    );
  }
}
