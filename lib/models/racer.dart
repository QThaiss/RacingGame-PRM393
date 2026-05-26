import 'package:flutter/material.dart';

/// Model representing a Racer in the game.
/// Contains basic information such as id, name, display icon, and color.
class Racer {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Racer({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
