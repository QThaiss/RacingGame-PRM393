import 'package:flutter/material.dart';
import '../models/racer.dart';

/// A widget representing a single racing track lane.
/// Draws a horizontal lane with starting line, finish area, and positions the racer based on progress.
class RaceLane extends StatelessWidget {
  final Racer racer;
  final double progress; // Value from 0.0 (start) to 1.0 (finish)
  final double racerSize;

  const RaceLane({
    Key? key,
    required this.racer,
    required this.progress,
    this.racerSize = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        // The maximum offset a racer can move before hitting the finish line
        final double maxMoveDistance = trackWidth - racerSize - 40; // reserve space for finish flag
        final double currentLeftOffset = progress * maxMoveDistance;

        return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Dotted Lane Marking (Asphalt divider line in center)
              Center(
                child: Row(
                  children: List.generate(
                    20,
                    (index) => Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: Colors.grey[700]!.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Start Line
              Positioned(
                left: 40,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),

              // 3. Finish Line (Checkered area & Flag)
              Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  color: Colors.redAccent.withOpacity(0.7),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      color: racer.color,
                      size: 24,
                    ),
                    Text(
                      'FINISH',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    )
                  ],
                ),
              ),

              // 4. Positioned Racer Icon
              AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                left: currentLeftOffset + 10, // padding offset from start
                top: 10,
                bottom: 10,
                child: SizedBox(
                  width: racerSize,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glow effect matching racer's color
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: racer.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: racer.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          racer.icon,
                          color: racer.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Small text showing the racer name
                      Text(
                        racer.name,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
