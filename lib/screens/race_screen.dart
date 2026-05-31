 import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../theme/f1_theme.dart';
import '../widgets/race_lane.dart';
import 'result_screen.dart';

/// Race screen — F1 broadcast HUD with original horizontal lanes.
/// Cars move left-to-right. F1-style 5-light start sequence, bet strip,
/// live leader display, and winner overlay.
class RaceScreen extends StatefulWidget {
  final double totalMoney;
  final Map<String, double> bets;
  final List<Racer> racers;

  const RaceScreen({
    super.key,
    required this.totalMoney,
    required this.bets,
    required this.racers,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  final Map<String, double> _positions = {};
  Timer? _raceTimer;
  Timer? _countdownTimer;
  bool _isRacing = false;
  int _countdown = 3;
  Racer? _winner;
  int _lightsLit = 0;

  @override
  void initState() {
    super.initState();
    for (var racer in widget.racers) {
      _positions[racer.id] = 0.0;
    }
    _startLightSequence();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _raceTimer?.cancel();
    super.dispose();
  }

  /// F1-style: lights go on one-by-one (5 reds), then all out = GO
  void _startLightSequence() {
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        if (_lightsLit < 5) {
          _lightsLit++;
          _countdown = 5 - _lightsLit;
        } else {
          _countdown = 0;
          _countdownTimer?.cancel();
          _startRace();
        }
      });
    });
  }

  void _startRace() {
    setState(() {
      _isRacing = true;
    });

    final Random random = Random();
    // Khởi tạo biến lưu trữ "tốc độ tức thời" cho mỗi xe để tạo hiệu ứng gia tốc/giảm tốc
    final Map<String, double> momentums = {};
    for (var racer in widget.racers) {
      momentums[racer.id] = 0.01 + random.nextDouble() * 0.01;
    }

    _raceTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var racer in widget.racers) {
          final double currentProgress = _positions[racer.id] ?? 0.0;
          
          // CẢI TIẾN: Tốc độ biến thiên (Variable Speed)
          // Đôi khi xe sẽ tăng tốc mạnh, đôi khi sẽ khựng lại một chút
          double drift = (random.nextDouble() - 0.48) * 0.005; 
          momentums[racer.id] = (momentums[racer.id]! + drift).clamp(0.005, 0.04);
          
          final double step = momentums[racer.id]!;
          final double newProgress = currentProgress + step;

          if (newProgress >= 1.0) {
            _positions[racer.id] = 1.0;
            _handleRaceFinish(racer);
            break;
          } else {
            _positions[racer.id] = newProgress;
          }
        }
      });
    });
  }

  void _handleRaceFinish(Racer winnerRacer) {
    _raceTimer?.cancel();
    setState(() {
      _isRacing = false;
      _winner = winnerRacer;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              winner: winnerRacer,
              totalMoney: widget.totalMoney,
              bets: widget.bets,
              racers: widget.racers,
            ),
          ),
        );
      }
    });
  }

  /// Compute sorted standings for leader display
  List<MapEntry<Racer, double>> _getSortedPositions() {
    final entries = widget.racers.map((r) => MapEntry(r, _positions[r.id] ?? 0.0)).toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _getSortedPositions();
    final orientation = MediaQuery.of(context).orientation;
    final double trackSpacing = orientation == Orientation.portrait ? 12.0 : 6.0;

    return Scaffold(
      backgroundColor: F1Colors.carbonBlack,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main race layout ──
            Column(
              children: [
                // Top bar
                _buildRaceTopBar(),

                // Bet summary strip
                _buildBetStrip(),

                // Horizontal race tracks (original Column layout)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: trackSpacing),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.racers.map((racer) {
                            return RaceLane(
                              racer: racer,
                              progress: _positions[racer.id] ?? 0.0,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom status bar
                _buildStatusBar(sorted),
              ],
            ),

            // ── Countdown / 5-light overlay ──
            if (_countdown > 0)
              _buildLightsOverlay(),

            // ── "LIGHTS OUT" overlay ──
            if (_countdown == 0 && !_isRacing && _winner == null)
              _buildGoOverlay(),

            // ── Winner overlay ──
            if (_winner != null)
              _buildWinnerOverlay(),
          ],
        ),
      ),
    );
  }

  /// F1 top header bar
  Widget _buildRaceTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: F1Colors.asphaltDark,
        border: Border(bottom: BorderSide(color: F1Colors.racingRed, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed, color: F1Colors.racingRed, size: 18),
          const SizedBox(width: 8),
          const Text(
            'RACE LIVE',
            style: TextStyle(
              color: F1Colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
          const Spacer(),
          if (_isRacing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: F1Colors.racingRed.withAlpha(30),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: F1Colors.racingRed),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: F1Colors.racingRed, size: 6),
                  SizedBox(width: 4),
                  Text(
                    'RACING',
                    style: TextStyle(
                      color: F1Colors.racingRed,
                      fontSize: 10,
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

  /// Compact bet summary strip
  Widget _buildBetStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: F1Colors.pitWallGray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.racers.map((racer) {
          final double bet = widget.bets[racer.id] ?? 0.0;
          return Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: racer.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${racer.name}: \$${bet.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: F1Colors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Bottom status / leader bar
  Widget _buildStatusBar(List<MapEntry<Racer, double>> sorted) {
    final String statusText;
    if (_winner != null) {
      statusText = '🏆 ${_winner!.name.toUpperCase()} WINS!';
    } else if (_isRacing) {
      final leader = sorted.first.key;
      statusText = 'LEADER: ${leader.name.toUpperCase()}';
    } else {
      statusText = 'FORMATION LAP...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: F1Colors.asphaltDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _winner != null ? Icons.emoji_events : Icons.timeline,
            color: _winner != null ? F1Colors.warningAmber : F1Colors.textMuted,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: _winner != null ? _winner!.color : F1Colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// F1 starting lights overlay (5 red lights, one-by-one)
  Widget _buildLightsOverlay() {
    return Container(
      color: Colors.black.withAlpha(220),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 5 lights row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final bool isLit = i < _lightsLit;
                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLit ? F1Colors.racingRed : F1Colors.panelGray,
                    border: Border.all(
                      color: isLit ? F1Colors.racingRed : F1Colors.borderGray,
                      width: 2,
                    ),
                    boxShadow: isLit
                        ? [
                            BoxShadow(
                              color: F1Colors.racingRed.withAlpha(150),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Text(
              '$_countdown',
              style: const TextStyle(
                color: F1Colors.textPrimary,
                fontSize: 72,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'FORMATION LAP',
              style: TextStyle(
                color: F1Colors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "LIGHTS OUT AND AWAY WE GO" flash overlay
  Widget _buildGoOverlay() {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _countdown == 0) {
        setState(() {
          _countdown = -1;
        });
      }
    });

    return Container(
      color: Colors.black.withAlpha(180),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LIGHTS OUT',
              style: TextStyle(
                color: F1Colors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'AND AWAY WE GO',
              style: TextStyle(
                color: F1Colors.signalGreen,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Winner celebration overlay — no borderRadius to avoid non-uniform border crash
  Widget _buildWinnerOverlay() {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        color: _winner!.color.withAlpha(25),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              color: F1Colors.asphaltDark,
              // No borderRadius — non-uniform border colors
              border: Border(
                top: BorderSide(color: _winner!.color, width: 4),
                left: const BorderSide(color: F1Colors.borderGray, width: 1),
                right: const BorderSide(color: F1Colors.borderGray, width: 1),
                bottom: const BorderSide(color: F1Colors.borderGray, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: _winner!.color.withAlpha(60),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: F1Colors.warningAmber, size: 48),
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
                Text(
                  _winner!.name.toUpperCase(),
                  style: TextStyle(
                    color: _winner!.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
