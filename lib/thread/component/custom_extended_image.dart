import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

class CustomExtendImage extends StatefulWidget {
  const CustomExtendImage({
    super.key,
    required this.url,
    required this.fit,
  });
  final String url;
  final BoxFit fit;

  @override
  State<CustomExtendImage> createState() => _CustomExtendImageState();
}

class _CustomExtendImageState extends State<CustomExtendImage> {
  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      widget.url,
      cache: true,
      compressionRatio: 0.5,
      fit: widget.fit,
    );
  }
}
