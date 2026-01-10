// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';

class InvoiceBottomPainter extends CustomPainter {
  final Color color;
  final String textDirection;

  InvoiceBottomPainter({super.repaint, required this.color,required this.textDirection});
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();
    paint.color = color;
    final path = Path();
    if (textDirection == 'ltr') {
      path.moveTo(0, size.height * 0.05);
      path.lineTo(0, size.height * 0.95);
      path.conicTo(0, size.height, size.width * 0.1, size.height, 0.7);
      path.lineTo(size.width * 0.9, size.height);
      path.conicTo(
          size.width, size.height, size.width, size.height * 0.95, 0.7);
      path.lineTo(size.width, size.height * 0.2);
      path.conicTo(size.width, size.height * 0.12, size.width * 0.85,
          size.height * 0.1, 0.7);
      path.lineTo(size.width * 0.15, 0);
      path.conicTo(
          size.width * 0.0, -size.height * 0.025, 0, size.height * 0.05, 0.7);
      path.close();
      canvas.drawPath(path, paint);
    } else {
      path.moveTo(size.width, size.height * 0.05);
      path.lineTo(size.width, size.height * 0.95);
      path.conicTo(size.width, size.height, size.width * 0.9, size.height, 0.7);
      path.lineTo(size.width * 0.1, size.height);
      path.conicTo(0, size.height, 0, size.height * 0.95, 0.7);

      path.lineTo(0, size.height * 0.2);
      path.conicTo(
          0, size.height * 0.12, size.width * 0.15, size.height * 0.1, 0.7);
      path.lineTo(size.width * 0.85, 0);
      path.conicTo(size.width, -size.height * 0.025, size.width,
          size.height * 0.05, 0.7);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
