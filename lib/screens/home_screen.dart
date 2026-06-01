import 'package:flutter/material.dart';
import '../models/racer.dart';
import '../models/bet.dart';
import '../theme/f1_theme.dart';
import '../widgets/racer_bet_card.dart';
import '../repositories/auth_repository.dart';
import 'race_screen.dart';
import 'login_screen.dart'; // Đăng xuất đẩy về đây

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRepository _authRepo = AuthRepository();
  late double _totalMoney; // Quản lý số tiền động của tài khoản hiện tại

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

  final Map<String, Bet> _bets = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Đọc số tiền thực tế lưu trong tài khoản của AuthRepository
    _totalMoney = _authRepo.currentUser?.balance ?? 100.0;

    for (var racer in _racers) {
      _bets[racer.id] = Bet(racer: racer, amount: 0.0);
      _controllers[racer.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    super.dispose();
  }

  // --- Logic Đăng xuất ---
  void _handleLogout() {
    _authRepo.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) =>
          false, // Xóa toàn bộ lịch sử các màn hình trước đó để tránh bấm nút back quay lại game
    );
  }

  double _calculateTotalBet() =>
      _bets.values.fold(0.0, (sum, bet) => sum + bet.amount);

  void _updateBetByAmount(String racerId, double increment) {
    setState(() {
      double currentBet = _bets[racerId]?.amount ?? 0.0;
      double newBet = currentBet + increment;
      if (newBet < 0) newBet = 0.0;
      _bets[racerId]?.amount = newBet;
      _controllers[racerId]?.text = newBet % 1 == 0
          ? newBet.toInt().toString()
          : newBet.toString();
    });
  }

  void _handleTextChange(String racerId, String value) {
    setState(() {
      double? parsedValue = double.tryParse(value);
      _bets[racerId]?.amount = (parsedValue == null || parsedValue < 0)
          ? 0.0
          : parsedValue;
    });
  }

  bool _isBankrupt() => _totalMoney <= 0 && _calculateTotalBet() <= 0;

  String? _getValidationError() {
    final double totalBet = _calculateTotalBet();
    if (totalBet == 0) return "Vui lòng đặt cược ít nhất một xe để bắt đầu!";
    if (totalBet > _totalMoney) return "Tổng cược vượt quá số tiền bạn có!";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totalBet = _calculateTotalBet();
    final remainingMoney = _totalMoney - totalBet;
    final validationError = _getValidationError();
    final bool canStart = validationError == null;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: F1Colors.carbonBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: isLandscape
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBalancePanel(remainingMoney),
                                  const SizedBox(height: 10),
                                  _buildStatsPanel(
                                    totalBet,
                                    remainingMoney,
                                    validationError,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildActionButton(canStart),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSectionHeader(
                                    'STARTING GRID',
                                    'Select driver & place bets',
                                  ),
                                  const SizedBox(height: 8),
                                  ..._racers.map(
                                    (racer) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: RacerBetCard(
                                        racer: racer,
                                        betAmount:
                                            _bets[racer.id]?.amount ?? 0.0,
                                        controller: _controllers[racer.id]!,
                                        onIncrement: () =>
                                            _updateBetByAmount(racer.id, 10.0),
                                        onDecrement: () =>
                                            _updateBetByAmount(racer.id, -10.0),
                                        onChanged: (val) =>
                                            _handleTextChange(racer.id, val),
                                      ),
                                    ),
                                  ),
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
                          _buildBalancePanel(remainingMoney),
                          const SizedBox(height: 20),
                          _buildSectionHeader(
                            'STARTING GRID',
                            'Select driver & place bets',
                          ),
                          const SizedBox(height: 12),
                          ..._racers.map(
                            (racer) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RacerBetCard(
                                racer: racer,
                                betAmount: _bets[racer.id]?.amount ?? 0.0,
                                controller: _controllers[racer.id]!,
                                onIncrement: () =>
                                    _updateBetByAmount(racer.id, 10.0),
                                onDecrement: () =>
                                    _updateBetByAmount(racer.id, -10.0),
                                onChanged: (val) =>
                                    _handleTextChange(racer.id, val),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatsPanel(
                            totalBet,
                            remainingMoney,
                            validationError,
                          ),
                          const SizedBox(height: 24),
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

  Widget _buildTopBar() {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isLandscape ? 4 : 8,
      ),
      decoration: const BoxDecoration(
        color: F1Colors.asphaltDark,
        border: Border(bottom: BorderSide(color: F1Colors.racingRed, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: F1Colors.racingRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'PIT WALL: ${_authRepo.currentUser?.username.toUpperCase()}',
            style: TextStyle(
              color: F1Colors.textPrimary,
              fontSize: isLandscape ? 13 : 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          // Nút Đăng xuất được thêm mới ở góc phải trên cùng thanh Bar
          IconButton(
            icon: const Icon(Icons.logout, color: F1Colors.textMuted, size: 20),
            tooltip: 'Đăng xuất tài khoản',
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePanel(double remainingMoney) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.pitWallGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: F1Colors.borderGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    color: F1Colors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${_totalMoney.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: F1Colors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: F1Colors.borderGray),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'AFTER BET',
                  style: TextStyle(
                    color: F1Colors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${remainingMoney.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: remainingMoney < 0
                        ? F1Colors.racingRed
                        : F1Colors.signalGreen,
                    fontSize: 24,
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(width: 3, height: 18, color: F1Colors.racingRed),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: F1Colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: F1Colors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsPanel(
    double totalBet,
    double remainingMoney,
    String? validationError,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              const Text(
                'TOTAL STAKE',
                style: TextStyle(
                  color: F1Colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '\$${totalBet.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: F1Colors.warningAmber,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (validationError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: F1Colors.racingRed.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: F1Colors.racingRed.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: F1Colors.racingRed,
                    size: 16,
                  ),
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

  Widget _buildActionButton(bool canStart) {
    if (_isBankrupt()) {
      return ElevatedButton(
        onPressed: () async {
          setState(() {
            _totalMoney = 100.0;
            for (var r in _racers) {
              _bets[r.id]?.amount = 0.0;
              _controllers[r.id]?.text = '0';
            }
          });
          // Đồng bộ reset tiền xuống SharedPreferences thông qua Repo
          await _authRepo.updateCurrentBalance(100.0);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: F1Colors.warningAmber,
          foregroundColor: F1Colors.carbonBlack,
        ),
        child: const Text('RESET \$100 BALANCE'),
      );
    }

    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: canStart
            ? const LinearGradient(
                colors: [F1Colors.racingRed, Color(0xFFB00500)],
              )
            : null,
        color: canStart ? null : F1Colors.panelGray,
      ),
      child: ElevatedButton(
        onPressed: canStart
            ? () async {
                final Map<String, double> betAmounts = _bets.map(
                  (key, bet) => MapEntry(key, bet.amount),
                );

                final double? newMoney = await Navigator.push<double>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RaceScreen(
                      totalMoney: _totalMoney,
                      bets: betAmounts,
                      racers: _racers,
                    ),
                  ),
                );
                if (newMoney != null) {
                  setState(() {
                    _totalMoney = newMoney;
                    for (var racer in _racers) {
                      _bets[racer.id]?.amount = 0.0;
                      _controllers[racer.id]?.text = '0';
                    }
                  });
                  // ĐẶC BIỆT: Đồng bộ cập nhật lưu số tiền mới của riêng user này xuống thiết bị bền vững
                  await _authRepo.updateCurrentBalance(newMoney);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'LIGHTS OUT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
