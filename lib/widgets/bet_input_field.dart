import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/f1_theme.dart';

/// A reusable bet input widget with decrement and increment buttons.
/// Styled with F1 dashboard aesthetics.
class BetInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onChanged;
  final Color accentColor;

  const BetInputField({
    super.key,
    required this.controller,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
    this.accentColor = F1Colors.racingRed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double controlBtnSize = isLandscape ? 34.0 : 40.0;
    final double inputWidth = isLandscape ? 56.0 : 64.0;
    final double inputFontSize = isLandscape ? 13.0 : 15.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(Icons.remove, onDecrement, controlBtnSize),
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
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
        ),
        _buildControlButton(Icons.add, onIncrement, controlBtnSize),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, double size) {
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
          child: Icon(icon, size: size * 0.5, color: accentColor),
        ),
      ),
    );
  }
}
