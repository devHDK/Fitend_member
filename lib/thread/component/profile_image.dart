import 'package:flutter/cupertino.dart';

class CircleProfileImage extends StatelessWidget {
  const CircleProfileImage({
    super.key,
    required this.image,
    required this.borderRadius,
  });

  final Image image;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}
