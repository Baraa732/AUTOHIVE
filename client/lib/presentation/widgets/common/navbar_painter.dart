import 'package:flutter/material.dart';

class NavbarPainter extends CustomPainter {
  final Color backgroundColor;
  final double cutoutPosition;
  final double cutoutWidth;
  final double cutoutHeight;
  final double radius;

  NavbarPainter({
    required this.backgroundColor,
    required this.cutoutPosition,
    required this.cutoutWidth,
    required this.cutoutHeight,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from top-left corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Draw to the start of the cutout
    final cutoutStart = cutoutPosition - (cutoutWidth / 2);
    path.lineTo(cutoutStart, 0);

    // Create the curved cutout
    path.quadraticBezierTo(
      cutoutStart + (cutoutWidth * 0.25), 
      -cutoutHeight * 0.5, 
      cutoutPosition, 
      -cutoutHeight
    );
    path.quadraticBezierTo(
      cutoutPosition + (cutoutWidth * 0.25), 
      -cutoutHeight * 0.5, 
      cutoutStart + cutoutWidth, 
      0
    );

    // Continue to top-right corner
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Draw right side
    path.lineTo(size.width, size.height);

    // Draw bottom side
    path.lineTo(0, size.height);

    // Close the path
    path.close();

    // Draw the navbar with shadow
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.3), 10, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavbarPainter oldDelegate) {
    return oldDelegate.cutoutPosition != cutoutPosition ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.cutoutWidth != cutoutWidth ||
           oldDelegate.cutoutHeight != cutoutHeight ||
           oldDelegate.radius != radius;
  }
}