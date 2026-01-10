import 'package:flutter/cupertino.dart';
import 'package:restart_tagxi/common/app_colors.dart';

class ReviewTopBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = AppColors.primary;
    final path = Path();

    path.lineTo(0, size.height);
    path.conicTo(size.width * 0.05, size.height * 0.6, size.width * 0.2,
        size.height * 0.8, 0.7);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
