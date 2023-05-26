import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(
        value: downloadProgress.progress,
        color: POINT_COLOR,
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        color: Colors.white,
      ),
      width: width ?? width,
      height: height ?? height,
      fit: BoxFit.cover,
    );
  }
}
