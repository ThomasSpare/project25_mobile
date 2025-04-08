// lib/screens/player/player_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evenstage_mobile/core/audio/audio_service.dart';
import 'package:evenstage_mobile/config/theme.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showDJMode = false;
  
  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);
    final currentTrack = audioService.currentTrack;
    
    if (currentTrack == null) {
      return const Scaffold(
        body: Center(
          child: Text('No track is currently playing'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<PlayerState>(
        stream: audioService.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final playing = playerState?.playing ?? false;
          
          return Stack(
            children: [
              // Main player content
              Column(
                children: [
                  // Album artwork
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(currentTrack.coverImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Track information
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTrack.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentTrack.artist.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: StreamBuilder<Duration?>(
                      stream: audioService.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        
                        return StreamBuilder<Duration?>(
                          stream: audioService.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            
                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14,
                                    ),
                                    activeTrackColor: AppTheme.amber200,
                                    inactiveTrackColor: Colors.grey[800],
                                    thumbColor: AppTheme.amber200,
                                    overlayColor: AppTheme.amber200.withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    value: position.inMilliseconds.toDouble().clamp(
                                      0, 
                                      duration.inMilliseconds.toDouble().max(0),
                                    ),
                                    max: duration.inMilliseconds.toDouble().max(1),
                                    onChanged: (value) {
                                      audioService.seek(Duration(
                                        milliseconds: value.toInt(),
                                      ));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(position),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Playback controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shuffle,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            // Implement shuffle
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 36,
                          ),
                          onPressed: () {
                            // Skip to previous
                          },
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.amber200,
                          ),
                          child: IconButton(
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              size: 36,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (playing) {
                                audioService.pause();
                              } else {
                                audioService.play();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 36,
                          ),
                          onPressed: () {
                            // Skip to next
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.radio,
                            color: _showDJMode ? AppTheme.amber200 : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _showDJMode = !_showDJMode;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // DJ Mode panel
              if (_showDJMode)
                DJModePanel(onClose: () {
                  setState(() {
                    _showDJMode = false;
                  });
                }),
            ],
          );
        },
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class DJModePanel extends StatefulWidget {
  final VoidCallback onClose;
  
  const DJModePanel({Key? key, required this.onClose}) : super(key: key);

  @override
  State<DJModePanel> createState() => _DJModePanelState();
}

class _DJModePanelState extends State<DJModePanel> {
  String _selectedLevel = 'scout';
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.radio, color: AppTheme.amber200),
                      SizedBox(width: 8),
                      Text(
                        'DJ Mode',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            
            // Current artist
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Based on Cosmic Harmony (Electronic)',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            
            // DJ level selection
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLevelButton('scout', 'Scout', Icons.bolt),
                      ),
                      Expanded(
                        child: _buildLevelButton('adventurer', 'Adventurer', Icons.explore),
                      ),
                      Expanded(
                        child: _buildLevelButton('voyager', 'Voyager', Icons.rocket),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _getDescription(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            
            // Artist suggestions
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildArtistSuggestion(index);
                },
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Refresh recommendations
                      },
                      child: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.amber200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Create mix
                      },
                      child: const Text('Create Mix'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelButton(String level, String label, IconData icon) {
    final isSelected = _selectedLevel == level;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.amber200 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildArtistSuggestion(int index) {
    final names = ['Lunar Synth', 'Ambient Dreams', 'Echo Waves'];
    final genres = ['Electronic', 'Ambient', 'Chillwave'];
    final matches = [90, 75, 60];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/seed/${index + 20}/300'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(names[index]),
        subtitle: Text(genres[index], style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getMatchColor(matches[index]),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${matches[index]}% match',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          // Play this artist
        },
      ),
    );
  }
  
  String _getDescription() {
    switch (_selectedLevel) {
      case 'scout':
        return 'Stay close to artists similar to what you\'re listening to now';
      case 'adventurer':
        return 'Discover related artists with some genre variation';
      case 'voyager':
        return 'Explore completely different sounds across various genres';
      default:
        return '';
    }
  }
  
  Color _getMatchColor(int match) {
    if (match > 70) return Colors.green;
    if (match > 40) return Colors.yellow;
    return Colors.red;
  }
}