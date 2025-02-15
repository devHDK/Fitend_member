import 'package:flutter/material.dart';

class TrianlgeCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, -1);
    path.lineTo(20, -1);
    path.lineTo(20, 13);
    path.lineTo(0, -1);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MyClipPath extends StatelessWidget {
  const MyClipPath({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TrianlgeCustomClipper(),
      child: Container(
        height: 13,
        width: 48,
        color: Colors.black.withOpacity(0.8),
      ),
    );
  }
}
