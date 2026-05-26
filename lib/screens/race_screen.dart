import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../widgets/race_lane.dart';
import 'result_screen.dart';

/// Screen where the race simulation takes place.
/// Displays tracks and uses a Timer.periodic to animate the racer icons based on random offsets.
class RaceScreen extends StatefulWidget {
  final double totalMoney;
  final Map<String, double> bets;
  final List<Racer> racers;

  const RaceScreen({
    Key? key,
    required this.totalMoney,
    required this.bets,
    required this.racers,
  }) : super(key: key);

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  // Store the progress (0.0 to 1.0) of each racer
  final Map<String, double> _positions = {};
  
  // Timer for racing updates
  Timer? _raceTimer;
  
  // State variables
  bool _isRacing = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  Racer? _winner;

  @override
  void initState() {
    super.initState();
    // Initialize positions of all racers to 0.0
    for (var racer in widget.racers) {
      _positions[racer.id] = 0.0;
    }
    // Automatically trigger countdown on screen entry
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _raceTimer?.cancel();
    super.dispose();
  }

  // Count down from 3 to 1 before starting the race
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          _countdown = 0; // 0 represents "GO!"
          _countdownTimer?.cancel();
          _startRace();
        }
      });
    });
  }

  // Start the periodic timer to move the racers
  void _startRace() {
    setState(() {
      _isRacing = true;
    });

    final Random random = Random();

    _raceTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var racer in widget.racers) {
          final double currentProgress = _positions[racer.id] ?? 0.0;
          
          // Random increment between 0.0 and 0.03
          final double step = random.nextDouble() * 0.03;
          final double newProgress = currentProgress + step;

          if (newProgress >= 1.0) {
            _positions[racer.id] = 1.0;
            _handleRaceFinish(racer);
            break; // Stop checking other racers once we have a winner
          } else {
            _positions[racer.id] = newProgress;
          }
        }
      });
    });
  }

  // Stop the race and navigate to results after a brief delay
  void _handleRaceFinish(Racer winnerRacer) {
    _raceTimer?.cancel();
    setState(() {
      _isRacing = false;
      _winner = winnerRacer;
    });

    // Pause for 1.5 seconds so user can see who crossed the line,
    // then replace this screen with ResultScreen in the stack.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ĐƯỜNG ĐUA RỰC LỬA'),
        centerTitle: true,
        backgroundColor: Colors.grey[950],
        automaticallyImplyLeading: false, // Prevent going back mid-race
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // --- Race Tracks Container ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header stats
                  _buildBettingSummaryHeader(),
                  const SizedBox(height: 20),

                  // Tracks list
                  Expanded(
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

                  const SizedBox(height: 20),
                  // Bottom Info
                  Text(
                    _isRacing
                        ? 'Các tay đua đang bứt tốc! 🚗⚡'
                        : (_winner != null ? '🎉 ${_winner!.name} ĐÃ CHIẾN THẮNG!' : 'Chuẩn bị xuất phát...'),
                    style: TextStyle(
                      color: _winner != null ? _winner!.color : Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // --- Countdown Overlay ---
            if (_countdown > 0)
              _buildCountdownOverlay()
            else if (_countdown == 0 && !_isRacing && _winner == null)
              _buildGoOverlay(),

            // --- Winner Confetti/Glow Overlay ---
            if (_winner != null)
              _buildWinnerOverlay(),
          ],
        ),
      ),
    );
  }

  // Summary of bets placed shown at the top of the race screen
  Widget _buildBettingSummaryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BẢNG ĐẶT CƯỢC CỦA BẠN',
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.racers.map((racer) {
              final double bet = widget.bets[racer.id] ?? 0.0;
              return Row(
                children: [
                  Icon(racer.icon, color: racer.color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${racer.name}: \$${bet.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  )
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Big numbered countdown (3, 2, 1) overlay
  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CHUẨN BỊ...',
              style: TextStyle(color: Colors.grey[400], fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // "GO!" overlay right before timer starts moving racers
  Widget _buildGoOverlay() {
    // Schedule a small setState to remove the "GO!" overlay after 500ms
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _countdown == 0) {
        setState(() {
          _countdown = -1; // hide go overlay
        });
      }
    });

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Text(
          'XUẤT PHÁT!',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 70,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // Dramatic visual overlay when a racer wins
  Widget _buildWinnerOverlay() {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        color: _winner!.color.withOpacity(0.15),
        child: Center(
          child: Card(
            color: Colors.grey[950],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _winner!.color, width: 2),
            ),
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    _winner!.name.toUpperCase(),
                    style: TextStyle(
                      color: _winner!.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'CHIẾN THẮNG!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
