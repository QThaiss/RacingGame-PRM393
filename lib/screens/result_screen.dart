import 'package:flutter/material.dart';
import '../models/racer.dart';

/// The Result Screen displaying the winning racer,
/// bet statistics, new total money calculation, and options to play again.
class ResultScreen extends StatelessWidget {
  final Racer winner;
  final double totalMoney;
  final Map<String, double> bets;
  final List<Racer> racers;

  const ResultScreen({
    Key? key,
    required this.winner,
    required this.totalMoney,
    required this.bets,
    required this.racers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Calculate financial details
    final double totalBet = bets.values.fold(0.0, (sum, val) => sum + val);
    final double winningBet = bets[winner.id] ?? 0.0;
    
    // Formula: newMoney = oldMoney - totalBet + winningBet * 2
    final double newMoney = totalMoney - totalBet + (winningBet * 2);
    final double netProfit = newMoney - totalMoney;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('KẾT QUẢ CUỘC ĐUA'),
        centerTitle: true,
        backgroundColor: Colors.grey[950],
        automaticallyImplyLeading: false, // Force navigation through explicit buttons
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Winner Announcement Panel ---
              _buildWinnerPanel(context),
              const SizedBox(height: 20),

              // --- Money Calculation Card ---
              _buildPayoutDetailsCard(totalBet, winningBet, newMoney, netProfit),
              const SizedBox(height: 20),

              // --- Detailed Stats Table ---
              const Text(
                'CHI TIẾT ĐẶT CƯỢC',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatsTable(),

              const SizedBox(height: 30),

              // --- Action Buttons ---
              // Buttons pop back to HomeScreen with the new money amount.
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, newMoney),
                icon: const Icon(Icons.replay),
                label: const Text(
                  'CHƠI LẠI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, newMoney),
                icon: const Icon(Icons.home),
                label: const Text(
                  'VỀ TRANG CHỦ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Visual header card presenting the winning racer
  Widget _buildWinnerPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: winner.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: winner.color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: winner.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 72,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'TAY ĐUA CHIẾN THẮNG',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Text(
            winner.name.toUpperCase(),
            style: TextStyle(
              color: winner.color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Icon(winner.icon, color: winner.color, size: 36),
        ],
      ),
    );
  }

  // Details regarding how money changed during the race
  Widget _buildPayoutDetailsCard(double totalBet, double winningBet, double newMoney, double netProfit) {
    final bool isGain = netProfit > 0;
    final bool isLoss = netProfit < 0;

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VỐN BAN ĐẦU', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('\$${totalMoney.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TÀI SẢN MỚI', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${newMoney.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 32, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biến động tài sản:',
                  style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isGain
                        ? Colors.greenAccent.withOpacity(0.1)
                        : (isLoss ? Colors.redAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGain ? Icons.arrow_upward : (isLoss ? Icons.arrow_downward : Icons.remove),
                        color: isGain ? Colors.greenAccent : (isLoss ? Colors.redAccent : Colors.grey),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isGain ? "+" : ""}\$${netProfit.abs().toStringAsFixed(1)}',
                        style: TextStyle(
                          color: isGain ? Colors.greenAccent : (isLoss ? Colors.redAccent : Colors.grey),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Generates the statistics summary grid/list
  Widget _buildStatsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Tay Đua', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Đã Cược', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Kết Quả', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Thưởng', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          
          // Table Rows
          ...racers.map((racer) {
            final double bet = bets[racer.id] ?? 0.0;
            final bool isWinner = racer.id == winner.id;
            final double payout = isWinner ? bet * 2 : 0.0;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[900]!, width: 1)),
              ),
              child: Row(
                children: [
                  // Racer Name and Icon
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Icon(racer.icon, color: racer.color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            racer.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bet Amount
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${bet.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  
                  // Win/Lose Status tag
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isWinner ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isWinner ? 'THẮNG' : 'THUA',
                          style: TextStyle(
                            color: isWinner ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Payout Amount
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${payout.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: payout > 0 ? Colors.greenAccent : Colors.white54,
                        fontWeight: payout > 0 ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
