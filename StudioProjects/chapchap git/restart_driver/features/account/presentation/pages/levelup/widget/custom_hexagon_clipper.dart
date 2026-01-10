import 'package:flutter/material.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Define the points for a hexagon
    path.moveTo(w * 0.5, 0); // Top center
    path.lineTo(w, h * 0.25); // Top right
    path.lineTo(w, h * 0.75); // Bottom right
    path.lineTo(w * 0.5, h); // Bottom center
    path.lineTo(0, h * 0.75); // Bottom left
    path.lineTo(0, h * 0.25); // Top left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
