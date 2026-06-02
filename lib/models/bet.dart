import 'racer.dart';

/// Model representing a bet placed by a user.
class Bet {
  final Racer racer;
  double amount;

  Bet({
    required this.racer,
    this.amount = 0.0,
  });

  /// Helper to check if the bet is active
  bool get isValid => amount > 0;

  /// Calculate payout (assuming x2 multiplier for simplicity, 
  /// can be made dynamic later)
  double calculatePayout(String winningRacerId) {
    if (racer.id == winningRacerId) {
      return amount * 2;
    }
    return 0.0;
  }
}
