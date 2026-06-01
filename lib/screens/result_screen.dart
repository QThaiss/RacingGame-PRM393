import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../theme/f1_theme.dart';
import '../services/prefs_service.dart';

/// Result screen — F1 Race Classification style.
/// Shows winner, payout breakdown, and detailed bet statistics.
class ResultScreen extends StatefulWidget {
  final Racer winner;
  final double totalMoney;
  final Map<String, double> bets;
  final List<Racer> racers;

  const ResultScreen({
    super.key,
    required this.winner,
    required this.totalMoney,
    required this.bets,
    required this.racers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Convenience getters so all helper methods keep working unchanged
  Racer get winner => widget.winner;
  double get totalMoney => widget.totalMoney;
  Map<String, double> get bets => widget.bets;
  List<Racer> get racers => widget.racers;

  @override
  void initState() {
    super.initState();
    final double totalBet = widget.bets.values.fold(0.0, (s, v) => s + v);
    final double winningBet = widget.bets[widget.winner.id] ?? 0.0;
    final double newMoney = widget.totalMoney - totalBet + (winningBet * 2);
    PrefsService.saveMoney(newMoney);
  }

  @override
  Widget build(BuildContext context) {

    final double totalBet = bets.values.fold(0.0, (sum, val) => sum + val);
    final double winningBet = bets[winner.id] ?? 0.0;
    final double newMoney = totalMoney - totalBet + (winningBet * 2);
    final double netProfit = newMoney - totalMoney;

    return Scaffold(
      backgroundColor: F1Colors.carbonBlack,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            _buildTopBar(),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Winner panel
                    _buildWinnerPanel(),
                    const SizedBox(height: 20),

                    // Financial summary
                    _buildFinancialSummary(totalBet, winningBet, newMoney, netProfit),
                    const SizedBox(height: 20),

                    // Race classification table
                    _buildSectionHeader('RACE CLASSIFICATION'),
                    const SizedBox(height: 10),
                    _buildClassificationTable(),
                    const SizedBox(height: 28),

                    // Action buttons
                    _buildActionButtons(context, newMoney),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top header bar
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: F1Colors.asphaltDark,
        border: Border(bottom: BorderSide(color: F1Colors.racingRed, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: F1Colors.warningAmber, size: 18),
          const SizedBox(width: 8),
          const Text(
            'RACE RESULT',
            style: TextStyle(
              color: F1Colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: F1Colors.textMuted),
            ),
            child: const Text(
              'FINAL',
              style: TextStyle(
                color: F1Colors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Winner display — podium card
  Widget _buildWinnerPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: F1Colors.pitWallGray,
        // No borderRadius — non-uniform border colors
        border: Border(
          top: BorderSide(color: winner.color, width: 4),
          left: const BorderSide(color: F1Colors.borderGray, width: 1),
          right: const BorderSide(color: F1Colors.borderGray, width: 1),
          bottom: const BorderSide(color: F1Colors.borderGray, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: winner.color.withAlpha(40),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // P1 badge
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.4), // Hiệu ứng phóng to P1 badge
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: winner.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: winner.color.withAlpha(80)),
                    ),
                    child: Text(
                      'P1',
                      style: TextStyle(
                        color: winner.color,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'RACE WINNER',
            style: TextStyle(
              color: F1Colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 6),

          // Car image
          SizedBox(
            height: 60,
            child: Image.asset(winner.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),

          Text(
            winner.name.toUpperCase(),
            style: TextStyle(
              color: winner.color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Financial summary card
  Widget _buildFinancialSummary(double totalBet, double winningBet, double newMoney, double netProfit) {
    final bool isGain = netProfit > 0;
    final bool isLoss = netProfit < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.pitWallGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: F1Colors.borderGray),
      ),
      child: Column(
        children: [
          // Before → After
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BEFORE',
                      style: TextStyle(
                        color: F1Colors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalMoney.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: F1Colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: F1Colors.textMuted, size: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'AFTER',
                      style: TextStyle(
                        color: F1Colors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${newMoney.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: F1Colors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: F1Colors.borderGray),
          const SizedBox(height: 12),

          // Net change
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NET CHANGE',
                style: TextStyle(
                  color: F1Colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isGain
                      ? F1Colors.signalGreen.withAlpha(25)
                      : (isLoss ? F1Colors.racingRed.withAlpha(25) : F1Colors.panelGray),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isGain
                        ? F1Colors.signalGreen.withAlpha(80)
                        : (isLoss ? F1Colors.racingRed.withAlpha(80) : F1Colors.borderGray),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGain ? Icons.trending_up : (isLoss ? Icons.trending_down : Icons.remove),
                      color: isGain ? F1Colors.signalGreen : (isLoss ? F1Colors.racingRed : F1Colors.textMuted),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isGain ? "+" : ""}\$${netProfit.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isGain ? F1Colors.signalGreen : (isLoss ? F1Colors.racingRed : F1Colors.textMuted),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section header
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: F1Colors.racingRed),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: F1Colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  /// Classification table — like F1 race results
  Widget _buildClassificationTable() {
    return Container(
      decoration: BoxDecoration(
        color: F1Colors.pitWallGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: F1Colors.borderGray),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: const BoxDecoration(
              color: F1Colors.asphaltDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('POS', style: TextStyle(color: F1Colors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1))),
                Expanded(flex: 3, child: Text('DRIVER', style: TextStyle(color: F1Colors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1))),
                Expanded(flex: 2, child: Text('STAKE', style: TextStyle(color: F1Colors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: F1Colors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('PAYOUT', style: TextStyle(color: F1Colors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1), textAlign: TextAlign.right)),
              ],
            ),
          ),

          // Data rows
          ...racers.asMap().entries.map((entry) {
            final int idx = entry.key;
            final racer = entry.value;
            final double bet = bets[racer.id] ?? 0.0;
            final bool isWinner = racer.id == winner.id;
            final double payout = isWinner ? bet * 2 : 0.0;
            final String pos = isWinner ? '1' : '${idx + 1}';

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: F1Colors.borderGray.withAlpha(100))),
                color: isWinner ? winner.color.withAlpha(15) : Colors.transparent,
              ),
              child: Row(
                children: [
                  // Position number
                  SizedBox(
                    width: 30,
                    child: Text(
                      pos,
                      style: TextStyle(
                        color: isWinner ? winner.color : F1Colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  // Driver name with team color accent
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 3, height: 18,
                          decoration: BoxDecoration(
                            color: racer.color,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            racer.name.toUpperCase(),
                            style: const TextStyle(
                              color: F1Colors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stake
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${bet.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: F1Colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // Win/Lose badge
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isWinner
                              ? F1Colors.signalGreen.withAlpha(25)
                              : F1Colors.racingRed.withAlpha(25),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: isWinner
                                ? F1Colors.signalGreen.withAlpha(80)
                                : F1Colors.racingRed.withAlpha(80),
                          ),
                        ),
                        child: Text(
                          isWinner ? 'WIN' : 'DNF',
                          style: TextStyle(
                            color: isWinner ? F1Colors.signalGreen : F1Colors.racingRed,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Payout
                  Expanded(
                    flex: 2,
                    child: Text(
                      payout > 0 ? '+\$${payout.toStringAsFixed(0)}' : '-',
                      style: TextStyle(
                        color: payout > 0 ? F1Colors.signalGreen : F1Colors.textMuted,
                        fontSize: 12,
                        fontWeight: payout > 0 ? FontWeight.w800 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Action buttons — styled like F1 broadcast UI
  Widget _buildActionButtons(BuildContext context, double newMoney) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [F1Colors.racingRed, Color(0xFFB00500)],
            ),
          ),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, newMoney),
            icon: const Icon(Icons.replay, size: 18),
            label: const Text(
              'RACE AGAIN',
              style: TextStyle(letterSpacing: 2.0),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, newMoney),
          icon: const Icon(Icons.home, size: 16),
          label: const Text('BACK TO PIT', style: TextStyle(letterSpacing: 1.5)),
          style: OutlinedButton.styleFrom(
            foregroundColor: F1Colors.textSecondary,
            side: const BorderSide(color: F1Colors.borderGray),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}
