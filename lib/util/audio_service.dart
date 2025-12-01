import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSoundEffectsEnabled = true;
  bool _isMusicPlaying = false;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('musicEnabled') ?? true;
    _isSoundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.3);
  }

  Future<void> playBackgroundMusic() async {
    if (_isMusicEnabled && !_isMusicPlaying) {
      try {
        await _musicPlayer.play(AssetSource('music/stupid-joke-indian-comedy-musicby-roshan-cariappa-117375.mp3'));
        _isMusicPlaying = true;
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _musicPlayer.pause();
      _isMusicPlaying = false;
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  Future<void> resumeBackgroundMusic() async {
    if (_isMusicEnabled && !_isMusicPlaying) {
      await _musicPlayer.resume();
      _isMusicPlaying = true;
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', enabled);

    if (enabled) {
      await playBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _isSoundEffectsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', enabled);
  }

  Future<void> _playEffect(String relativeAssetPath) async {
    if (!_isSoundEffectsEnabled) return;
    try {
      await _effectsPlayer.stop();
      await _effectsPlayer.play(AssetSource(relativeAssetPath));
    } catch (e) {
      print('Error playing sound effect $relativeAssetPath: $e');
    }
  }

  Future<void> playCorrectSound() async {
    await _playEffect('sounds/the-correct-answer-33-183620.mp3');
  }

  Future<void> playIncorrectSound() async {
    await _playEffect('sounds/wrong-answer-21-199825.mp3');
  }

  Future<void> playButtonClickSound() async {
    await _playEffect('sounds/new-message-31-183617.mp3');
  }

  Future<void> playCountdownSound() async {
    await _playEffect('sounds/game-countdown-62-199828.mp3');
  }

  Future<void> playGameOverSound() async {
    await _playEffect('sounds/game-over-39-199830.mp3');
  }

  void dispose() {
    _musicPlayer.dispose();
    _effectsPlayer.dispose();
  }
}
