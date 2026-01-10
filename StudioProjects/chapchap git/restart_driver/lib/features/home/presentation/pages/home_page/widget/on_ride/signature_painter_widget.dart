//signamture drawing
import 'package:flutter/material.dart';

class SignaturePainterWidget extends CustomPainter {
  List pointlist;
  Color color;
  SignaturePainterWidget({required this.pointlist, required this.color});

  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = color;
    Paint dot = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 5
      ..color = color;
    Path path = Path();
    Path paths = Path();
    path.moveTo(0, 0);
    for (int i = 0; i < pointlist.length - 1; i++) {
      if (pointlist[i]['action'] == 'move to') {
        path.moveTo(pointlist[i]['point'].dx, pointlist[i]['point'].dy);
      } else if (pointlist[i]['action'] == 'dot to') {
        paths.moveTo(pointlist[i]['point'].dx, pointlist[i]['point'].dy);
        paths
            .addOval(Rect.fromCircle(center: pointlist[i]['point'], radius: 2));
      } else if (pointlist[i]['action'] == 'setstate') {
      } else {
        path.lineTo(pointlist[i]['point'].dx, pointlist[i]['point'].dy);
      }
    }
    canvas.drawPath(paths, dot);
    canvas.drawPath(path, line);
  }

  //Called when CustomPainter is rebuilt.
  //Returning true because we want canvas to be rebuilt to reflect new changes.
  @override
  bool shouldRepaint(SignaturePainterWidget oldDelegate) => true;
}
