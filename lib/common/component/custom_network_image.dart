import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? boxFit;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      // progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: Center(
      //     child: CircularProgressIndicator(
      //       value: downloadProgress.progress,
      //       color: Pallete.point,
      //     ),
      //   ),
      // ),
      errorWidget: (context, url, error) =>
          Image.asset('asset/launcher/fitend_logo.png'),
      width: width ?? width,
      height: height ?? height,
      fit: boxFit ?? boxFit,
    );
  }
}
