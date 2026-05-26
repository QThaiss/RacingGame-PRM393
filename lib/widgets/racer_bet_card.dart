import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/racer.dart';

/// A card widget to display a racer and handle their betting input.
/// Provides +/- buttons and a text input field for direct entry.
class RacerBetCard extends StatelessWidget {
  final Racer racer;
  final double betAmount;
  final TextEditingController controller;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onChanged;

  const RacerBetCard({
    Key? key,
    required this.racer,
    required this.betAmount,
    required this.controller,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color scheme based on racer color for a premium cohesive look
    final Color primaryColor = racer.color;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          // Soft gradient matching racer's theme
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.05),
              primaryColor.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Racer Icon and color tag
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Icon(
                racer.icon,
                color: primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            // Racer details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    racer.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: primaryColor.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payout: x2',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bet inputs: Minus, TextField, Plus
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus button
                _buildRoundButton(
                  icon: Icons.remove,
                  color: primaryColor,
                  onTap: onDecrement,
                ),
                
                // Text Field Input
                Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      // Allow only numbers and a single decimal point
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: onChanged,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                ),
                
                // Plus button
                _buildRoundButton(
                  icon: Icons.add,
                  color: primaryColor,
                  onTap: onIncrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper builder for custom round buttons
  Widget _buildRoundButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
            color: color.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }
}
