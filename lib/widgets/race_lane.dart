import 'dart:math';
import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../theme/f1_theme.dart';

/// Painted texture for the asphalt surface — adds grain, subtle variation
/// and a more realistic road feel using CustomPainter.
class _AsphaltPainter extends CustomPainter {
  _AsphaltPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    // Base: already covered by gradient container; draw subtle grain dots
    paint.color = Colors.black.withAlpha(18);
    for (int i = 0; i < size.width.toInt() * 3; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      paint.color = rng.nextBool()
          ? Colors.white.withAlpha(6)
          : Colors.black.withAlpha(14);
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AsphaltPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

/// Dashed center lane marking painter — cleaner than 24 containers.
class _LaneMarkingPainter extends CustomPainter {
  _LaneMarkingPainter({required this.color, required this.seed});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashCount = 20;
    final dashWidth = size.width / (dashCount * 2);
    final y = size.height / 2;

    for (int i = 0; i < dashCount; i++) {
      final startX = i * dashWidth * 2;
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth * 0.7, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LaneMarkingPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Rumble strip painter — alternating red/white chevron pattern on lane edges.
class _RumbleStripPainter extends CustomPainter {
  _RumbleStripPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const stripeCount = 12;
    final stripeH = size.height / stripeCount;

    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < stripeCount; i++) {
      paint.color = i.isEven
          ? F1Colors.racingRed
          : Colors.white.withAlpha(200);
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeH, 6, stripeH), paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RumbleStripPainter oldDelegate) => false;
}

/// Checkered flag pattern painter — 8×8 grid at the finish line.
class _CheckeredPainter extends CustomPainter {
  _CheckeredPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 8;
    const cols = 6;
    final cw = size.width / cols;
    final ch = size.height / rows;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        paint.color = (r + c).isEven ? Colors.white : Colors.black;
        canvas.drawRect(
          Rect.fromLTWH(c * cw, r * ch, cw, ch),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckeredPainter oldDelegate) => false;
}

/// Distance marker ticks along the bottom of the lane.
class _DistanceMarkerPainter extends CustomPainter {
  _DistanceMarkerPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = F1Colors.textMuted.withAlpha(100)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final intervals = [0.25, 0.50, 0.75];
    for (final t in intervals) {
      final x = t * size.width;
      canvas.drawLine(
        Offset(x, size.height - 6),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DistanceMarkerPainter oldDelegate) => false;
}

/// Horizontal race lane — F1-style with CustomPainter textures, rumble strips,
/// checkered finish, and smooth car animation.
class RaceLane extends StatelessWidget {
  final Racer racer;
  final double progress; // 0.0 (start) to 1.0 (finish)
  final double racerSize;
  final double wobble;

  const RaceLane({
    super.key,
    required this.racer,
    required this.progress,
    this.racerSize = 80.0,
    this.wobble = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final double laneHeight =
        orientation == Orientation.portrait ? 80.0 : 50.0;
    final double laneMargin =
        orientation == Orientation.portrait ? 6.0 : 3.0;
    final bool isPortrait = orientation == Orientation.portrait;

    return Container(
      height: laneHeight,
      margin: EdgeInsets.symmetric(vertical: laneMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            // ── 1. Asphalt base with gradient ──
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2A2A2E),
                    Color(0xFF1C1C20),
                    Color(0xFF2A2A2E),
                  ],
                ),
                border: Border(
                  left: BorderSide(color: racer.color, width: 5),
                  right: BorderSide(
                      color: F1Colors.borderGray.withAlpha(180), width: 1),
                  top: const BorderSide(color: F1Colors.borderGray, width: 0.5),
                  bottom:
                      const BorderSide(color: F1Colors.borderGray, width: 0.5),
                ),
              ),
            ),

            // ── 2. Asphalt grain texture ──
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: CustomPaint(
                  painter: _AsphaltPainter(seed: racer.id.hashCode),
                ),
              ),
            ),

            // ── 3. Rumble strip — left edge (team color background) ──
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Row(
                children: [
                  Container(
                    width: 5,
                    color: racer.color,
                  ),
                  SizedBox(
                    width: 5,
                    child: CustomPaint(
                      size: const Size(5, 80),
                      painter: _RumbleStripPainter(seed: racer.id.hashCode),
                    ),
                  ),
                ],
              ),
            ),

            // ── 4. Rumble strip — right edge ──
            Positioned(
              right: 32,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 5,
                child: CustomPaint(
                  size: const Size(5, 80),
                  painter: _RumbleStripPainter(seed: racer.id.hashCode + 1),
                ),
              ),
            ),

            // ── 5. Center lane markings (dashed line) ──
            Positioned(
              left: 20,
              right: 40,
              top: 0,
              bottom: 0,
              child: CustomPaint(
                painter: _LaneMarkingPainter(
                  color: F1Colors.textMuted.withAlpha(60),
                  seed: racer.id.hashCode,
                ),
              ),
            ),

            // ── 6. Distance marker ticks ──
            Positioned(
              left: 20,
              right: 40,
              bottom: 0,
              top: 0,
              child: CustomPaint(
                painter: _DistanceMarkerPainter(seed: racer.id.hashCode),
              ),
            ),

            // ── 7. Start line (subtle vertical mark) ──
            Positioned(
              left: 50,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.white.withAlpha(50)),
            ),
            Positioned(
              left: 53,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: Colors.white.withAlpha(30)),
            ),

            // ── 8. Finish line — checkered pattern ──
            Positioned(
              right: 38,
              top: 0,
              bottom: 0,
              width: 8,
              child: CustomPaint(
                painter: _CheckeredPainter(),
              ),
            ),
            // Finish line glow
            Positioned(
              right: 37,
              top: 0,
              bottom: 0,
              width: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      racer.color.withAlpha(100),
                      Colors.white.withAlpha(200),
                      racer.color.withAlpha(100),
                    ],
                  ),
                ),
              ),
            ),

            // ── 9. Finish flag icon ──
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.flag,
                  color: F1Colors.textMuted,
                  size: isPortrait ? 18 : 14,
                ),
              ),
            ),

            // ── 10. Driver name tag ──
            Positioned(
              left: 14,
              top: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: F1Colors.carbonBlack.withAlpha(200),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: racer.color.withAlpha(120),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  racer.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: racer.color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // ── 11. Progress percentage ──
            Positioned(
              right: 50,
              bottom: 4,
              child: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: F1Colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // ── 12. Animated car — smooth left-to-right movement ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              curve: Curves.linear,
              left: 20 + progress * (MediaQuery.of(context).size.width - racerSize - 100) + 12,
              top: (isPortrait ? 10.0 : 5.0) + wobble,
              bottom: (isPortrait ? 10.0 : 5.0) - wobble,
              child: Container(
                width: racerSize,
                decoration: BoxDecoration(
                  boxShadow: progress > 0 && progress < 1.0
                      ? [
                          BoxShadow(
                            color: racer.color.withAlpha(140),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(-14, 0),
                          ),
                          BoxShadow(
                            color: racer.color.withAlpha(60),
                            blurRadius: 40,
                            spreadRadius: 2,
                            offset: const Offset(-8, 0),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: racer.color.withAlpha(80),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(-4, 0),
                          ),
                        ],
                ),
                child: Image.asset(
                  racer.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
