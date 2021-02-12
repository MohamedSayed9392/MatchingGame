import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  Offset start;
  Offset end;
  LinePainter(this.start, this.end);
  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null) return;
    canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = 4
          ..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
