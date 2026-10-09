import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final int pieces;
  final Duration duration;
  const ConfettiOverlay({super.key, this.pieces = 40, this.duration = const Duration(seconds: 3)});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Piece> _items;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    final rand = Random();
    _items = List.generate(widget.pieces, (i) {
      return _Piece(
        x: rand.nextDouble(),
        delay: rand.nextDouble() * 0.4,
        speed: 0.6 + rand.nextDouble() * 0.6,
        color: [
          const Color(0xFF00A651),
          const Color(0xFF00C853),
          const Color(0xFFFFC107),
          const Color(0xFF2E90FA),
          const Color(0xFFF04438),
        ][i % 5],
        size: 6 + rand.nextDouble() * 8,
        rotation: rand.nextDouble() * 6.28,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            painter: _ConfettiPainter(_items, _ctrl.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Piece {
  final double x;
  final double delay;
  final double speed;
  final Color color;
  final double size;
  final double rotation;
  _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final localT = ((t - p.delay) * p.speed).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final x = p.x * size.width;
      final y = -20 + localT * (size.height + 40);
      final paint = Paint()..color = p.color.withValues(alpha: 1 - localT * 0.5);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + localT * 6);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}