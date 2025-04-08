// lib/core/audio/audio_service.dart
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import '../../models/track.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();
  
  final AudioPlayer _player = AudioPlayer();
  
  // Getters for UI to observe player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  
  // Initialize the service
  Future<void> init() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.evenstage.app.channel.audio',
      androidNotificationChannelName: 'EvenStage',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    );
    
    // Listen to playback state changes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Handle track completion - move to next track
      }
    });
  }
  
  // Play a track
  Future<void> playTrack(Track track) async {
    final audioSource = AudioSource.uri(
      Uri.parse(track.audioUrl),
      tag: MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist.name,
        artUri: Uri.parse(track.coverImage),
        duration: track.duration,
      ),
    );
    
    await _player.setAudioSource(audioSource);
    await _player.play();
  }
  
  // Playback controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  
  // DJ Mode - Play similar artists
  Future<void> playDJMode(List<Track> recommendations) async {
    final playlist = ConcatenatingAudioSource(
      children: recommendations.map((track) => AudioSource.uri(
        Uri.parse(track.audioUrl),
        tag: MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist.name,
          artUri: Uri.parse(track.coverImage),
          duration: track.duration,
        ),
      )).toList(),
    );
    
    await _player.setAudioSource(playlist, initialIndex: 0);
    await _player.play();
  }
  
  void dispose() {
    _player.dispose();
  }
}