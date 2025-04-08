import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evenstage/core/audio/audio_service.dart';
import 'package:evenstage/config/theme.dart';
import 'package:evenstage/core/audio/player_state.dart';
import 'package:evenstage/core/audio/track.dart';


class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);
    
    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        
        // If no track is loaded, don't show the player
        if (playerState == null) return const SizedBox.shrink();
        
        return Container(
          height: 64,
          color: Colors.black,
          child: Row(
            children: [
              // Track artwork
              Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: const DecorationImage(
                    image: NetworkImage('placeholder-url'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Song Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Artist Name',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Controls
              IconButton(
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: AppTheme.amber200,
                ),
                onPressed: () {
                  if (playing) {
                    audioService.pause();
                  } else {
                    audioService.play();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}