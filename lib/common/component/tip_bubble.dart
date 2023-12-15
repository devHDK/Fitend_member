import 'package:flutter/material.dart';

enum BubblePosition {
  bottomLeft,
  bottomCenter,
  bottomRight,
  left,
  right,
}

class TipBubble extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color bubbleColor;
  final BubblePosition bubblePosition;
  double? distance;

  TipBubble({
    super.key,
    required this.text,
    required this.textStyle,
    required this.bubbleColor,
    required this.bubblePosition,
    this.distance = 20,
  });

  @override
  Widget build(BuildContext context) {
    GlobalKey containerKey = GlobalKey();

    return Stack(
      children: [
        Container(
          key: containerKey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            text,
            style: textStyle,
          ),
        ),
        Positioned(
          bottom: 0,
          right: bubblePosition == BubblePosition.right ? 0 : null,
          left: bubblePosition == BubblePosition.left ? 0 : null,
          child: CustomPaint(
            painter: BubbleTail(
              bubblePosition: bubblePosition,
              color: bubbleColor,
              globalKey: containerKey,
              distance: distance!,
            ),
          ),
        ),
      ],
    );
  }
}

class BubbleTail extends CustomPainter {
  final BubblePosition bubblePosition;
  final Color color;
  final GlobalKey globalKey;
  final double distance;

  BubbleTail({
    required this.bubblePosition,
    required this.color,
    required this.globalKey,
    required this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    RenderBox containerBox =
        globalKey.currentContext!.findRenderObject() as RenderBox;
    Size containerSize = containerBox.size;

    switch (bubblePosition) {
      case BubblePosition.bottomLeft:
        path.moveTo(distance, 0);
        path.lineTo(distance + 4, 8);
        path.lineTo(distance + 8, 0);
        break;
      case BubblePosition.bottomCenter:
        path.moveTo((containerSize.width / 2) - 4, 0);
        path.lineTo(containerSize.width / 2, 8);
        path.lineTo(containerSize.width / 2 + 4, 0);
        path.lineTo(0, size.height);
        break;
      case BubblePosition.bottomRight:
        path.moveTo(containerSize.width - distance, 0);
        path.lineTo(containerSize.width - (distance - 4), 8);
        path.lineTo(containerSize.width - (distance - 8), 0);
        break;
      case BubblePosition.left:
        path.moveTo(0, -(containerSize.height / 2 - 4));
        path.lineTo(-8, -(containerSize.height / 2));
        path.lineTo(0, -(containerSize.height / 2 + 4));
        break;
      case BubblePosition.right:
        path.moveTo(0, -(containerSize.height / 2 - 4));
        path.lineTo(8, -(containerSize.height / 2));
        path.lineTo(0, -(containerSize.height / 2 + 4));
        break;
    }

    Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubbleTail oldDelegate) {
    return oldDelegate.bubblePosition != bubblePosition ||
        oldDelegate.color != color;
  }
}
