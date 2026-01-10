import 'package:flutter/cupertino.dart';
import 'package:restart_tagxi/common/app_colors.dart';

class InvoiceTopPainter extends CustomPainter {
  final String textDirection;

  InvoiceTopPainter({required this.textDirection});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = AppColors.primary;
    final path = Path();
    if (textDirection == 'ltr') {
      path.lineTo(0, size.height * 0.4);
      path.conicTo(size.width * 0.05, size.height * 0.55, size.width * 0.2,
          size.height * 0.6, 0.7);
      path.lineTo(size.width * 0.8, size.height * 0.8);
      path.conicTo(size.width, size.height * 0.85, size.width, size.height, 1);

      path.lineTo(size.width, 0);
      path.close();
      canvas.drawPath(path, paint);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.4);
      path.conicTo(size.width * 0.95, size.height * 0.55, size.width * 0.8,
          size.height * 0.6, 0.7);
      path.lineTo(size.width * 0.2, size.height * 0.8);
      path.conicTo(0, size.height * 0.85, 0, size.height, 1);

      path.lineTo(0, 0);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
