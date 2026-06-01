import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../theme/f1_theme.dart';

/// Horizontal race lane — left-to-right car animation.
/// Styled with F1 asphalt aesthetics: team color left strip, dashed lane
/// markings, start/finish lines, and car image positioned by progress.
/// [wobble] is a pre-computed vertical offset (−1..1) managed by the parent
/// so Random() is never called inside build.
class RaceLane extends StatelessWidget {
  final Racer racer;
  final double progress; // 0.0 (start) to 1.0 (finish)
  final double racerSize;
  final double wobble; // vertical jitter controlled by RaceScreen

  const RaceLane({
    super.key,
    required this.racer,
    required this.progress,
    this.racerSize = 80.0,
    this.wobble = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        final double maxMoveDistance = trackWidth - racerSize - 40;
        final double currentLeftOffset = progress * maxMoveDistance;

        final orientation = MediaQuery.of(context).orientation;
        final double laneHeight = orientation == Orientation.portrait ? 80.0 : 50.0;
        final double laneMargin = orientation == Orientation.portrait ? 6.0 : 3.0;

        return Container(
          height: laneHeight,
          margin: EdgeInsets.symmetric(vertical: laneMargin),
          decoration: BoxDecoration(
            // Subtle asphalt gradient for depth
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                F1Colors.panelGray,
                F1Colors.pitWallGray,
                F1Colors.panelGray,
              ],
            ),
            border: Border(
              left: BorderSide(color: racer.color, width: 4),
              top: const BorderSide(color: F1Colors.borderGray, width: 0.5),
              right: const BorderSide(color: F1Colors.borderGray, width: 0.5),
              bottom: const BorderSide(color: F1Colors.borderGray, width: 0.5),
            ),
          ),
          child: Stack(
            children: [
              // 1. Dashed lane markings (horizontal center line)
              Center(
                child: Row(
                  children: List.generate(
                    24,
                    (index) => Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        color: F1Colors.borderGray.withAlpha(80),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Start line (vertical white line)
              Positioned(
                left: 44,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: F1Colors.textMuted.withAlpha(60),
                ),
              ),

              // 3. Finish line (red vertical strip + checkered pattern)
              Positioned(
                right: 36,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: F1Colors.racingRed.withAlpha(180),
                ),
              ),
              // Finish flag
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      color: F1Colors.textMuted,
                      size: orientation == Orientation.portrait ? 20 : 14,
                    ),
                  ],
                ),
              ),

              // 4. Driver name tag (left side inside lane)
              Positioned(
                left: 8,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: F1Colors.carbonBlack.withAlpha(180),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    racer.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: racer.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // 5. Progress percentage (right side)
              Positioned(
                right: 48,
                bottom: 4,
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: F1Colors.textMuted,
                  ),
                ),
              ),

              // 6. Animated car image — smooth left-to-right movement
              AnimatedPositioned(
                duration: const Duration(milliseconds: 80),
                curve: Curves.linear,
                left: currentLeftOffset + 12,
                top: (orientation == Orientation.portrait ? 10.0 : 5.0) + wobble,
                bottom: (orientation == Orientation.portrait ? 10.0 : 5.0) - wobble,
                child: Container(
                  width: racerSize,
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (progress > 0 && progress < 1.0)
                        BoxShadow(
                          color: racer.color.withAlpha(120),
                          blurRadius: 18,
                          spreadRadius: 3,
                          offset: const Offset(-12, 0),
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
        );
      },
    );
  }
}
