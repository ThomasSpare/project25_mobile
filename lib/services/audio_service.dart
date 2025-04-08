import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:evenstage_mobile/models/track.dart';
import 'package:evenstage_mobile/core/audio/player_state.dart';

class AudioPlayerService extends ChangeNotifier {
  final _player = AudioPlayer();
  Track? _currentTrack;
  PlayerState _state = PlayerState.stopped;

  Track? get currentTrack => _currentTrack;
  PlayerState get state => _state;
  bool get isPlaying => _state == PlayerState.playing;

  Future<void> playTrack(Track track) async {
    try {
      _state = PlayerState.loading;
      notifyListeners();
      
      await _player.setUrl(track.audioUrl);
      _currentTrack = track;
      await _player.play();
      
      _state = PlayerState.playing;
      notifyListeners();
    } catch (e) {
      _state = PlayerState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _state = PlayerState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.play();
    _state = PlayerState.playing;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}