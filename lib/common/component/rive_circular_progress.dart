import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveCircularProgress extends StatelessWidget {
  final double size;
  const RiveCircularProgress({
    super.key,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: const RiveAnimation.asset(
        'asset/rive/circular_progress_indicator.riv',
      ),
    );
  }
}
