import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../theme/f1_theme.dart';
import '../widgets/racer_bet_card.dart';
import 'race_screen.dart';

/// Home / Betting screen — styled as an F1 Race Control pit wall dashboard.
/// Manages balance, bets, validation, and navigation to the RaceScreen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalMoney = 100.0;

  final List<Racer> _racers = [
    Racer(
      id: 'car_1',
      name: 'Red Thunder',
      icon: Icons.directions_car,
      color: const Color(0xFFE10600),
      imagePath: 'assets/images/car_red.png',
    ),
    Racer(
      id: 'car_2',
      name: 'Blue Cyclone',
      icon: Icons.directions_car,
      color: const Color(0xFF00D2FF),
      imagePath: 'assets/images/car_blue.png',
    ),
    Racer(
      id: 'car_3',
      name: 'Yellow Typhoon',
      icon: Icons.directions_car,
      color: const Color(0xFFFFAB00),
      imagePath: 'assets/images/car_yellow.png',
    ),
  ];

  final Map<String, double> _bets = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var racer in _racers) {
      _bets[racer.id] = 0.0;
      _controllers[racer.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _calculateTotalBet() {
    return _bets.values.fold(0.0, (sum, item) => sum + item);
  }

  void _updateBetByAmount(String racerId, double increment) {
    setState(() {
      double currentBet = _bets[racerId] ?? 0.0;
      double newBet = currentBet + increment;
      if (newBet < 0) newBet = 0.0;
      _bets[racerId] = newBet;
      _controllers[racerId]?.text = newBet % 1 == 0 ? newBet.toInt().toString() : newBet.toString();
    });
  }

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

  bool _isBankrupt() {
    return _totalMoney <= 0 && _calculateTotalBet() <= 0;
  }

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
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: F1Colors.carbonBlack,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar: Race Control header ──
            _buildTopBar(),

            // ── Content ──
            Expanded(
              child: isLandscape
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Control Panel (fixed column, scrollable if tiny)
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBalancePanel(remainingMoney),
                                  const SizedBox(height: 10),
                                  _buildStatsPanel(totalBet, remainingMoney, validationError),
                                  const SizedBox(height: 12),
                                  _buildActionButton(canStart),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right: Starting Grid / Bet cards
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSectionHeader('STARTING GRID', 'Select driver & place bets'),
                                  const SizedBox(height: 8),
                                  ..._racers.map((racer) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: RacerBetCard(
                                        racer: racer,
                                        betAmount: _bets[racer.id] ?? 0.0,
                                        controller: _controllers[racer.id]!,
                                        onIncrement: () => _updateBetByAmount(racer.id, 10.0),
                                        onDecrement: () => _updateBetByAmount(racer.id, -10.0),
                                        onChanged: (val) => _handleTextChange(racer.id, val),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Balance panel
                          _buildBalancePanel(remainingMoney),
                          const SizedBox(height: 20),

                          // Section header
                          _buildSectionHeader('STARTING GRID', 'Select driver & place bets'),
                          const SizedBox(height: 12),

                          // Driver cards
                          ..._racers.map((racer) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RacerBetCard(
                                racer: racer,
                                betAmount: _bets[racer.id] ?? 0.0,
                                controller: _controllers[racer.id]!,
                                onIncrement: () => _updateBetByAmount(racer.id, 10.0),
                                onDecrement: () => _updateBetByAmount(racer.id, -10.0),
                                onChanged: (val) => _handleTextChange(racer.id, val),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),

                          // Stats panel
                          _buildStatsPanel(totalBet, remainingMoney, validationError),
                          const SizedBox(height: 24),

                          // Action button
                          _buildActionButton(canStart),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom AppBar — F1 Race Control style
  Widget _buildTopBar() {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLandscape ? 8 : 12),
      decoration: const BoxDecoration(
        color: F1Colors.asphaltDark,
        border: Border(bottom: BorderSide(color: F1Colors.racingRed, width: 2)),
      ),
      child: Row(
        children: [
          // Red accent dot
          Container(
            width: isLandscape ? 6 : 8,
            height: isLandscape ? 6 : 8,
            decoration: const BoxDecoration(
              color: F1Colors.racingRed,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isLandscape ? 8 : 10),
          Text(
            'RACE CONTROL',
            style: TextStyle(
              color: F1Colors.textPrimary,
              fontSize: isLandscape ? 13 : 16,
              fontWeight: FontWeight.w800,
              letterSpacing: isLandscape ? 2.0 : 3.0,
            ),
          ),
          const Spacer(),
          // Live indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: isLandscape ? 6 : 8, vertical: isLandscape ? 2 : 3),
            decoration: BoxDecoration(
              border: Border.all(color: F1Colors.signalGreen, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: F1Colors.signalGreen, size: 6),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: F1Colors.signalGreen,
                    fontSize: isLandscape ? 8 : 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Balance display — like a broadcast timing tower money readout
  Widget _buildBalancePanel(double remainingMoney) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double padding = isLandscape ? 10.0 : 16.0;
    final double titleSize = isLandscape ? 8.5 : 10.0;
    final double primaryValSize = isLandscape ? 22.0 : 32.0;
    final double secondaryValSize = isLandscape ? 18.0 : 24.0;
    final double dividerHeight = isLandscape ? 36.0 : 50.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: F1Colors.pitWallGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: F1Colors.borderGray),
      ),
      child: Row(
        children: [
          // Left: Total balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    color: F1Colors.textMuted,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: isLandscape ? 3.0 : 6.0),
                Text(
                  '\$${_totalMoney.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: F1Colors.textPrimary,
                    fontSize: primaryValSize,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          // Vertical divider
          Container(width: 1, height: dividerHeight, color: F1Colors.borderGray),
          SizedBox(width: isLandscape ? 10.0 : 16.0),
          // Right: Remaining after bet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'AFTER BET',
                  style: TextStyle(
                    color: F1Colors.textMuted,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: isLandscape ? 3.0 : 6.0),
                Text(
                  '\$${remainingMoney.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: remainingMoney < 0 ? F1Colors.racingRed : F1Colors.signalGreen,
                    fontSize: secondaryValSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section header label
  Widget _buildSectionHeader(String title, String subtitle) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Red accent bar
        Container(width: 3, height: isLandscape ? 14 : 18, color: F1Colors.racingRed),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: F1Colors.textPrimary,
                fontSize: isLandscape ? 12 : 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: F1Colors.textMuted,
                fontSize: isLandscape ? 9 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bet stats panel + validation errors
  Widget _buildStatsPanel(double totalBet, double remainingMoney, String? validationError) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      padding: EdgeInsets.all(isLandscape ? 10 : 14),
      decoration: BoxDecoration(
        color: F1Colors.pitWallGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: F1Colors.borderGray),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL STAKE',
                style: TextStyle(
                  color: F1Colors.textSecondary,
                  fontSize: isLandscape ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '\$${totalBet.toStringAsFixed(0)}',
                style: TextStyle(
                  color: F1Colors.warningAmber,
                  fontSize: isLandscape ? 15 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (validationError != null) ...[
            SizedBox(height: isLandscape ? 8 : 12),
            Container(
              padding: EdgeInsets.all(isLandscape ? 6 : 10),
              decoration: BoxDecoration(
                color: F1Colors.racingRed.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: F1Colors.racingRed.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: F1Colors.racingRed, size: isLandscape ? 14 : 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationError,
                      style: const TextStyle(
                        color: F1Colors.racingRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Main action button: Start Race or Reset
  Widget _buildActionButton(bool canStart) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double buttonHeight = isLandscape ? 44.0 : 54.0;
    final double fontSize = isLandscape ? 13.0 : 16.0;

    if (_isBankrupt()) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _totalMoney = 100.0;
            for (var r in _racers) {
              _bets[r.id] = 0.0;
              _controllers[r.id]?.text = '0';
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: F1Colors.warningAmber,
          foregroundColor: F1Colors.carbonBlack,
          padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
        ),
        child: const Text('RESET \$100 BALANCE'),
      );
    }

    return Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: canStart
            ? const LinearGradient(colors: [F1Colors.racingRed, Color(0xFFB00500)])
            : null,
        color: canStart ? null : F1Colors.panelGray,
      ),
      child: ElevatedButton(
        onPressed: canStart
            ? () async {
                final double? newMoney = await Navigator.push<double>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RaceScreen(
                      totalMoney: _totalMoney,
                      bets: Map.from(_bets),
                      racers: _racers,
                    ),
                  ),
                );
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
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow,
              color: canStart ? Colors.white : F1Colors.textMuted,
              size: isLandscape ? 20 : 24,
            ),
            const SizedBox(width: 8),
            Text(
              'LIGHTS OUT',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: canStart ? Colors.white : F1Colors.textMuted,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
