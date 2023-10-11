import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key, required this.diretoryPath});

  final String diretoryPath;

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          photoPathBuilder: () {
            return Future.value(widget.diretoryPath);
          },
          videoPathBuilder: () {
            return Future.value(widget.diretoryPath);
          },
          initialCaptureMode: CaptureMode.photo,
        ),
      ),
    );
  }
}
