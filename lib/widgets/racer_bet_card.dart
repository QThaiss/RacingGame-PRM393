import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/racer.dart';
import '../theme/f1_theme.dart';

/// Driver card styled like an F1 starting grid entry.
/// Shows car image, driver name, payout odds, and bet controls.
class RacerBetCard extends StatelessWidget {
  final Racer racer;
  final double betAmount;
  final TextEditingController controller;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onChanged;

  const RacerBetCard({
    super.key,
    required this.racer,
    required this.betAmount,
    required this.controller,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = racer.color;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final double cardPaddingX = isLandscape ? 10.0 : 14.0;
    final double cardPaddingY = isLandscape ? 8.0 : 12.0;
    final double imgWidth = isLandscape ? 60.0 : 80.0;
    final double imgHeight = isLandscape ? 36.0 : 50.0;
    final double titleFontSize = isLandscape ? 13.0 : 16.0;
    final double controlBtnSize = isLandscape ? 34.0 : 40.0;
    final double inputWidth = isLandscape ? 56.0 : 64.0;
    final double inputFontSize = isLandscape ? 13.0 : 15.0;

    return Container(
      decoration: BoxDecoration(
        color: F1Colors.panelGray,
        // No borderRadius — non-uniform border colors require sharp edges
        // (also more authentic to F1 broadcast UI)
        border: Border(
          left: BorderSide(color: accent, width: 4),
          top: const BorderSide(color: F1Colors.borderGray, width: 0.5),
          right: const BorderSide(color: F1Colors.borderGray, width: 0.5),
          bottom: const BorderSide(color: F1Colors.borderGray, width: 0.5),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: cardPaddingX, vertical: cardPaddingY),
      child: Row(
        children: [
          // Car image container
          Container(
            width: imgWidth,
            height: imgHeight,
            decoration: BoxDecoration(
              color: F1Colors.asphaltDark,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(racer.imagePath, fit: BoxFit.contain),
          ),
          SizedBox(width: isLandscape ? 10.0 : 14.0),

          // Driver name + payout label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  racer.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: F1Colors.textPrimary,
                    letterSpacing: isLandscape ? 0.4 : 0.8,
                  ),
                ),
                SizedBox(height: isLandscape ? 2.0 : 4.0),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 5 : 6, vertical: isLandscape ? 1.5 : 2),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(40),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'x2',
                        style: TextStyle(
                          fontSize: isLandscape ? 9.0 : 11.0,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PAYOUT',
                      style: TextStyle(
                        fontSize: isLandscape ? 8.0 : 10.0,
                        fontWeight: FontWeight.w600,
                        color: F1Colors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bet controls: [ - ] [ input ] [ + ]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(Icons.remove, accent, onDecrement, controlBtnSize),
              Container(
                width: inputWidth,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: onChanged,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.w700,
                    color: F1Colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: isLandscape ? 6 : 8),
                    filled: true,
                    fillColor: F1Colors.carbonBlack,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: F1Colors.borderGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                  ),
                ),
              ),
              _buildControlButton(Icons.add, accent, onIncrement, controlBtnSize),
            ],
          ),
        ],
      ),
    );
  }

  /// Square control button with team accent color.
  Widget _buildControlButton(IconData icon, Color color, VoidCallback onTap, double size) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: F1Colors.borderGray, width: 1),
            color: F1Colors.asphaltDark,
          ),
          child: Icon(icon, size: size * 0.5, color: color),
        ),
      ),
    );
  }
}
