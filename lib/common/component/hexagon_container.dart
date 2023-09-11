import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonContainer extends StatelessWidget {
  final Color color;
  final Color lineColor;
  final Color labelColor;
  final double size;
  final String label;

  const HexagonContainer({
    super.key,
    required this.color,
    required this.size,
    required this.lineColor,
    required this.label,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _HexagonPainter(color, lineColor),
          size: Size(size, size),
        ),
        Positioned(
          left: 14,
          top: 2.5,
          child: Text(
            label,
            style: h3Headline.copyWith(
              color: labelColor,
            ),
          ),
        )
      ],
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final Color lineColor;

  _HexagonPainter(this.color, this.lineColor);

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.lineColor != lineColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / math.sqrt(3);
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final path = Path();

    // 시작 각도를 조정합니다.
    path.moveTo(centerX + radius * math.cos(math.pi / -2),
        centerY + radius * math.sin(math.pi / -2));

    for (int i = -1; i <= 4; i++) {
      double angle = (math.pi / -2) + ((2 * math.pi) / 6 * (i + 1));
      path.lineTo(centerX + radius * math.cos(angle),
          centerY + radius * math.sin(angle));
    }

    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // 선만 그리고 싶다면 아래 코드 주석 해제
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
