import 'package:flutter/material.dart';

// Stylised arch + cross app symbol (32×32 viewBox, scaled to [size])
class AppSymbol extends StatelessWidget {
  final double size;
  final Color? color;

  const AppSymbol({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return CustomPaint(
      size: Size(size, size),
      painter: _AppSymbolPainter(color: c),
    );
  }
}

class _AppSymbolPainter extends CustomPainter {
  final Color color;
  const _AppSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Arch body: M16 4 C 11 4 8 7 8 12 V 26 C 8 27.1 8.9 28 10 28 H 22 ...
    final arch = Path()
      ..moveTo(16 * scale, 4 * scale)
      ..cubicTo(11 * scale, 4 * scale, 8 * scale, 7 * scale, 8 * scale, 12 * scale)
      ..lineTo(8 * scale, 26 * scale)
      ..cubicTo(8 * scale, 27.1 * scale, 8.9 * scale, 28 * scale, 10 * scale, 28 * scale)
      ..lineTo(22 * scale, 28 * scale)
      ..cubicTo(23.1 * scale, 28 * scale, 24 * scale, 27.1 * scale, 24 * scale, 26 * scale)
      ..lineTo(24 * scale, 12 * scale)
      ..cubicTo(24 * scale, 7 * scale, 21 * scale, 4 * scale, 16 * scale, 4 * scale)
      ..close();
    canvas.drawPath(arch, paint);

    // Cross vertical: M16 9 V 16
    canvas.drawLine(
      Offset(16 * scale, 9 * scale),
      Offset(16 * scale, 16 * scale),
      paint,
    );
    // Cross horizontal: M13 12.5 H19
    canvas.drawLine(
      Offset(13 * scale, 12.5 * scale),
      Offset(19 * scale, 12.5 * scale),
      paint,
    );

    // Dot at (16, 22) r=1 — filled
    canvas.drawCircle(
      Offset(16 * scale, 22 * scale),
      1 * scale,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_AppSymbolPainter old) => old.color != color;
}
