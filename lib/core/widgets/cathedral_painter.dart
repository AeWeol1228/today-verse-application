import 'dart:math' as math;
import 'package:flutter/material.dart';

// Procedural stipple cathedral illustration — ported from designs/1/stipple.jsx
class CathedralStipple extends StatelessWidget {
  final double width;
  final Color color;

  const CathedralStipple({super.key, this.width = 320, required this.color});

  @override
  Widget build(BuildContext context) {
    final h = width * (560 / 400);
    return CustomPaint(
      size: Size(width, h),
      painter: _CathedralPainter(color: color),
    );
  }
}

class _CathedralPainter extends CustomPainter {
  final Color color;

  // Generated once, shared across all instances (deterministic seed).
  static final List<_Dot> _dots = _buildDots();

  _CathedralPainter({required this.color});

  static List<_Dot> _buildDots() {
    final rng = _Mulberry32(7);
    final dots = <_Dot>[];

    // ── Geometry (400 × 560 canvas) ─────────────────────────
    const bayX0 = 135.0, bayX1 = 265.0, bayTop = 150.0, bayBottom = 470.0;
    const roseCx = 200.0, roseCy = 235.0, roseR = 38.0;
    const doorX0 = 178.0, doorX1 = 222.0, doorTop = 340.0, doorBot = 460.0;

    bool inBay(double x, double y) =>
        x >= bayX0 && x <= bayX1 && y >= bayTop && y <= bayBottom;

    bool inGable(double x, double y) {
      if (y < 95 || y > bayTop) return false;
      final t = (y - 95) / (bayTop - 95);
      return (x - 200).abs() <= (bayX1 - bayX0) / 2 * t;
    }

    bool inRoseRing(double x, double y) {
      final d = math.sqrt(
          (x - roseCx) * (x - roseCx) + (y - roseCy) * (y - roseCy));
      return d >= roseR - 4 && d <= roseR + 4;
    }

    bool inDoor(double x, double y) {
      if (x < doorX0 || x > doorX1 || y > doorBot) return false;
      final cx = (doorX0 + doorX1) / 2;
      final r = (doorX1 - doorX0) / 2;
      if (y < doorTop) {
        return math.sqrt(
                (x - cx) * (x - cx) + (y - doorTop) * (y - doorTop)) <=
            r + 3;
      }
      return true;
    }

    // Stroke a line as a dense dot sequence
    void strokeLine(double x1, double y1, double x2, double y2,
        {double width = 1.2}) {
      final len =
          math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
      if (len == 0) return;
      final n = (len * 1.6).floor();
      final nx = -(y2 - y1) / len;
      final ny = (x2 - x1) / len;
      for (int i = 0; i <= n; i++) {
        for (int k = 0; k < 2; k++) {
          final t = n == 0 ? 0.0 : i / n;
          final off = (rng.next() - 0.5) * width;
          dots.add(_Dot(
            x1 + (x2 - x1) * t + nx * off + (rng.next() - 0.5) * 0.6,
            y1 + (y2 - y1) * t + ny * off + (rng.next() - 0.5) * 0.6,
            0.38 + rng.next() * 0.22,
          ));
        }
      }
    }

    // ── Structural outlines ──────────────────────────────────
    // Left spire
    strokeLine(118, 60, 95, 470);
    strokeLine(118, 60, 138, 470);
    strokeLine(95, 470, 138, 470);
    // Right spire
    strokeLine(282, 60, 262, 470);
    strokeLine(282, 60, 305, 470);
    strokeLine(262, 470, 305, 470);
    // Nave walls
    strokeLine(bayX0, bayTop, bayX0, bayBottom);
    strokeLine(bayX1, bayTop, bayX1, bayBottom);
    strokeLine(bayX0, bayBottom, bayX1, bayBottom);
    // Gable
    strokeLine(bayX0, bayTop, 200, 95);
    strokeLine(bayX1, bayTop, 200, 95);

    // ── Rose window ──────────────────────────────────────────
    for (int i = 0; i < 48; i++) {
      final a = i / 48 * 2 * math.pi;
      dots.add(_Dot(
        roseCx + (roseR + (rng.next() - 0.5) * 3) * math.cos(a),
        roseCy + (roseR + (rng.next() - 0.5) * 3) * math.sin(a),
        0.35 + rng.next() * 0.3,
      ));
    }
    for (int s = 0; s < 8; s++) {
      final a = s / 8 * 2 * math.pi;
      strokeLine(roseCx, roseCy, roseCx + roseR * math.cos(a),
          roseCy + roseR * math.sin(a),
          width: 0.6);
    }

    // ── Door arch ────────────────────────────────────────────
    final doorCx = (doorX0 + doorX1) / 2;
    final doorR = (doorX1 - doorX0) / 2;
    for (int i = 0; i <= 20; i++) {
      final a = math.pi + i / 20 * math.pi;
      dots.add(_Dot(
        doorCx + doorR * math.cos(a) + (rng.next() - 0.5) * 1.2,
        doorTop + doorR * math.sin(a) + (rng.next() - 0.5) * 1.2,
        0.4 + rng.next() * 0.2,
      ));
    }
    strokeLine(doorX0, doorTop, doorX0, doorBot);
    strokeLine(doorX1, doorTop, doorX1, doorBot);

    // ── Shading fill — nave body ─────────────────────────────
    var added = 0;
    var tries = 0;
    while (added < 420 && tries < 420 * 12) {
      tries++;
      final x = 100 + rng.next() * 200;
      final y = 55 + rng.next() * 430;
      if (!inBay(x, y) && !inGable(x, y)) continue;
      if (inRoseRing(x, y) || inDoor(x, y)) continue;
      final t = 0.3 + 0.7 * ((y - 55) / 430);
      if (rng.next() > t) continue;
      dots.add(_Dot(
        x + (rng.next() - 0.5) * 2,
        y + (rng.next() - 0.5) * 2,
        0.3 + rng.next() * 0.55 * (0.5 + 0.5 * t),
      ));
      added++;
    }

    return dots;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 400.0;
    final scaleY = size.height / 560.0;
    final s = (scaleX + scaleY) / 2;
    final paint = Paint()..color = color;
    for (final d in _dots) {
      canvas.drawCircle(Offset(d.x * scaleX, d.y * scaleY), d.r * s, paint);
    }
  }

  @override
  bool shouldRepaint(_CathedralPainter old) => old.color != color;
}

class _Dot {
  final double x, y, r;
  const _Dot(this.x, this.y, this.r);
}

class _Mulberry32 {
  int _s;
  _Mulberry32(int seed) : _s = seed;

  double next() {
    _s = (_s + 0x6D2B79F5) & 0xFFFFFFFF;
    int t = _s;
    t = ((t ^ (t >> 15)) * (t | 1)) & 0xFFFFFFFF;
    t = (t ^ (t + ((t ^ (t >> 7)) * (t | 61)))) & 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296.0;
  }
}
