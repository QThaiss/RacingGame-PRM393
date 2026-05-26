import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../widgets/racer_bet_card.dart';
import 'race_screen.dart';

/// The main Home / Betting screen.
/// Allows players to view their balance, place bets on racers, validates their input,
/// and starts the race once bet requirements are satisfied.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Player's total money, default is 100
  double _totalMoney = 100.0;

  // List of racers
  final List<Racer> _racers = [
    Racer(id: 'car_1', name: 'Red Thunder', icon: Icons.directions_car, color: Colors.redAccent),
    Racer(id: 'car_2', name: 'Blue Cyclone', icon: Icons.sports_motorsports, color: Colors.blueAccent),
    Racer(id: 'car_3', name: 'Green Lightning', icon: Icons.electric_car, color: Colors.greenAccent),
  ];

  // Track the bet amount for each racer
  final Map<String, double> _bets = {};

  // Controllers to sync direct keyboard inputs with the state
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize bets to 0 and create controllers for each racer
    for (var racer in _racers) {
      _bets[racer.id] = 0.0;
      _controllers[racer.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid memory leaks
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Calculates the sum of all current bets
  double _calculateTotalBet() {
    return _bets.values.fold(0.0, (sum, item) => sum + item);
  }

  // Handle updating bet amounts from +/- buttons
  void _updateBetByAmount(String racerId, double increment) {
    setState(() {
      double currentBet = _bets[racerId] ?? 0.0;
      double newBet = currentBet + increment;
      if (newBet < 0) newBet = 0.0;

      // Update map and text controller
      _bets[racerId] = newBet;
      
      // format without decimal points if it's an integer
      _controllers[racerId]?.text = newBet % 1 == 0 ? newBet.toInt().toString() : newBet.toString();
    });
  }

  // Handle text field changes
  void _handleTextChange(String racerId, String value) {
    setState(() {
      double? parsedValue = double.tryParse(value);
      if (parsedValue == null || parsedValue < 0) {
        _bets[racerId] = 0.0;
      } else {
        _bets[racerId] = parsedValue;
      }
    });
  }

  // Check if player has run out of money and has no bets placed
  bool _isBankrupt() {
    return _totalMoney <= 0 && _calculateTotalBet() <= 0;
  }

  // Validation rules for starting the race
  String? _getValidationError() {
    final double totalBet = _calculateTotalBet();
    if (totalBet == 0) {
      return "Vui lòng đặt cược ít nhất một xe để bắt đầu!";
    }
    if (totalBet > _totalMoney) {
      return "Tổng cược (\$${totalBet.toStringAsFixed(1)}) vượt quá số tiền bạn có (\$${_totalMoney.toStringAsFixed(1)})!";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totalBet = _calculateTotalBet();
    final remainingMoney = _totalMoney - totalBet;
    final validationError = _getValidationError();
    final bool canStart = validationError == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏁 MINI RACING GAME',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[950],
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Welcome and Balance Dashboard Banner ---
              _buildBalanceBanner(remainingMoney),
              const SizedBox(height: 20),

              // --- Racer Betting List ---
              const Text(
                'CHỌN XE & ĐẶT CƯỢC',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              // Build betting cards
              ..._racers.map((racer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: RacerBetCard(
                    racer: racer,
                    betAmount: _bets[racer.id] ?? 0.0,
                    controller: _controllers[racer.id]!,
                    onIncrement: () => _updateBetByAmount(racer.id, 10.0),
                    onDecrement: () => _updateBetByAmount(racer.id, -10.0),
                    onChanged: (val) => _handleTextChange(racer.id, val),
                  ),
                );
              }).toList(),

              const SizedBox(height: 10),

              // --- Validation Alert & Stats Card ---
              _buildStatsAndValidationCard(totalBet, remainingMoney, validationError),

              const SizedBox(height: 24),

              // --- Action Buttons ---
              if (_isBankrupt())
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _totalMoney = 100.0;
                      // reset all bets
                      for (var r in _racers) {
                        _bets[r.id] = 0.0;
                        _controllers[r.id]?.text = '0';
                      }
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('NHẬN LẠI \$100 KHỞI NGHIỆP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: canStart
                        ? const LinearGradient(
                            colors: [Colors.purpleAccent, Colors.deepPurple],
                          )
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: canStart
                        ? () async {
                            // Navigate to race screen and await the updated money returned
                            final double? newMoney = await Navigator.push<double>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RaceScreen(
                                  totalMoney: _totalMoney,
                                  bets: Map.from(_bets), // pass copy
                                  racers: _racers,
                                ),
                              ),
                            );

                            // Update total money and reset bets for next game
                            if (newMoney != null) {
                              setState(() {
                                _totalMoney = newMoney;
                                for (var racer in _racers) {
                                  _bets[racer.id] = 0.0;
                                  _controllers[racer.id]?.text = '0';
                                }
                              });
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'BẮT ĐẦU ĐUA 🏁',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a beautiful display of the player's balance info
  Widget _buildBalanceBanner(double remainingMoney) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SỐ DƯ HIỆN TẠI',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${_totalMoney.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SỐ TIỀN CÒN LẠI',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${remainingMoney.toStringAsFixed(1)}',
                style: TextStyle(
                  color: remainingMoney < 0 ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Summary statistics card + validation error display
  Widget _buildStatsAndValidationCard(double totalBet, double remainingMoney, String? validationError) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền đặt cược:', style: TextStyle(color: Colors.white70)),
              Text(
                '\$${totalBet.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          if (validationError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationError,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
