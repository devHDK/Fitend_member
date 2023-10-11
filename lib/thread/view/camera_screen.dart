import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isRecording = false;
  double zoomLevel = 0.0; // between 0.0 and maxZoomLevel
  double maxZoomLevel = 0.0;
  List<CameraDescription> cameras = [];
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller.initialize();
      setMaxZoomLevel();
      isCameraInitialized = true;

      print(isCameraInitialized);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> init() async {
    cameras = await availableCameras();
  }

  void setMaxZoomLevel() async {
    maxZoomLevel = await controller.getMaxZoomLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isCameraInitialized
            ? Stack(children: <Widget>[
                Positioned.fill(
                    child: GestureDetector(
                  child: CameraPreview(controller),
                  onScaleUpdate: (details) {
                    zoomLevel += details.scale - 1;

                    if (zoomLevel < 0.0) {
                      zoomLevel = 0.0;
                    } else if (zoomLevel > maxZoomLevel) {
                      zoomLevel = maxZoomLevel;
                    }

                    controller.setZoomLevel(zoomLevel);
                  },
                )),
                Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton.extended(
                      onPressed: _toggleRecording,
                      label: Text(
                          isRecording ? "Stop Recording" : "Start Recording"),
                    ))
              ])
            :
            // Otherwise, display a loading indicator.
            const Center(child: CircularProgressIndicator()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.camera),
          onPressed: () async {
            try {
              final image = await controller.takePicture();

              print(image.path);
            } catch (e) {
              print(e);
            }
          },
        ));
  }

  void _toggleRecording() {
    if (isRecording) {
      controller.stopVideoRecording();
    } else {
      controller.startVideoRecording();
    }

    setState(() {
      isRecording = !isRecording;
    });
  }
}
