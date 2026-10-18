import 'package:flutter/material.dart';

class CollectionAtmosphere {
  const CollectionAtmosphere(
    this.background,
    this.light,
    this.margin,
    this.duration,
    this.tracking,
    this.geometric,
  );
  final Color background;
  final Color light;
  final double margin;
  final int duration;
  final double tracking;
  final bool geometric;
  static CollectionAtmosphere forName(String name) => switch (name) {
    'geometric' => const CollectionAtmosphere(
      Color(0xFF151719),
      Color(0xFF33383B),
      28,
      480,
      3,
      true,
    ),
    'expansive' => const CollectionAtmosphere(
      Color(0xFF151E23),
      Color(0xFF34464E),
      64,
      650,
      2,
      false,
    ),
    'monochrome' => const CollectionAtmosphere(
      Color(0xFF111111),
      Color(0xFF303030),
      40,
      520,
      4,
      false,
    ),
    _ => const CollectionAtmosphere(
      Color(0xFF0E1813),
      Color(0xFF2F4132),
      36,
      600,
      2,
      false,
    ),
  };
}

class AtmosphereSurface extends StatelessWidget {
  const AtmosphereSurface({
    super.key,
    required this.atmosphere,
    required this.child,
  });
  final CollectionAtmosphere atmosphere;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: atmosphere.background,
      gradient: RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 1.1,
        colors: [atmosphere.light, atmosphere.background],
      ),
    ),
    child: CustomPaint(painter: _ArchitectureLines(atmosphere), child: child),
  );
}

class _ArchitectureLines extends CustomPainter {
  _ArchitectureLines(this.atmosphere);
  final CollectionAtmosphere atmosphere;
  @override
  void paint(Canvas canvas, Size size) {
    if (!atmosphere.geometric) return;
    final paint = Paint()
      ..color = const Color(0x334A5359)
      ..strokeWidth = 1;
    for (final x in [0.08, 0.92]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x, size.height),
        paint,
      );
    }
    canvas.drawLine(
      Offset(0, size.height * 0.78),
      Offset(size.width, size.height * 0.78),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArchitectureLines old) =>
      old.atmosphere.geometric != atmosphere.geometric;
}
