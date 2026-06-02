import 'package:audioplayers/audioplayers.dart';

/// Singleton audio manager. All methods are fire-and-forget; if an audio
/// asset is missing the error is swallowed so the game always runs.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _countdownPlayer = AudioPlayer();

  bool _muted = false;
  bool get isMuted => _muted;

  Future<void> _playSfx(String asset) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$asset'));
    } catch (_) {}
  }

  Future<void> _playCountdownSfx(String asset) async {
    if (_muted) return;
    try {
      await _countdownPlayer.stop();
      await _countdownPlayer.setReleaseMode(ReleaseMode.stop);
      await _countdownPlayer.play(AssetSource('audio/$asset'), volume: 1);
    } catch (_) {}
  }

  Future<void> playBgMusic(String asset) async {
    if (_muted) return;
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(0.4);
      await _bgPlayer.play(AssetSource('audio/$asset'));
    } catch (_) {}
  }

  Future<void> stopBgMusic() async {
    try {
      await _bgPlayer.stop();
    } catch (_) {}
  }

  Future<void> fadeBgMusic() async {
    try {
      for (double v = 0.4; v >= 0; v -= 0.05) {
        await _bgPlayer.setVolume(v < 0 ? 0 : v);
        await Future.delayed(const Duration(milliseconds: 40));
      }
      await _bgPlayer.stop();
    } catch (_) {}
  }

  Future<void> playRaceCountdownTick() => _playCountdownSfx('race_start.mp3');
  Future<void> playRaceStart() => playRaceCountdownTick();
  Future<void> playRaceBg() => playBgMusic('race_bg.mp3');
  Future<void> playWin() => _playSfx('win.mp3');
  Future<void> playLose() => _playSfx('lose.mp3');
  Future<void> playHomeBg() => playBgMusic('bg_music.mp3');
  Future<void> playBetIncrease() => _playSfx('bet_tick.wav');

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _bgPlayer.setVolume(0);
      _sfxPlayer.setVolume(0);
      _countdownPlayer.setVolume(0);
    } else {
      _bgPlayer.setVolume(0.4);
      _sfxPlayer.setVolume(1);
      _countdownPlayer.setVolume(1);
    }
  }

  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    _countdownPlayer.dispose();
  }
}
