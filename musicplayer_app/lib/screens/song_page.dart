// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:musicplayer_app/models/song.dart';
import 'package:musicplayer_app/providers/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer_app/widgets/neu_box.dart';

class SongPage extends StatefulWidget {
  final Song song;

  SongPage({required this.song});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        // get playlist
        final playlist = value.playlist;

        // get current song
        final currentSong = playlist[value.currentSongIndex ?? 0];

        return Scaffold(
          appBar: AppBar(title: Text('PLAYING NOW')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // header
                NeuBox(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            currentSong.albumArtImagePath,
                            scale: 0.7,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${currentSong.songName.toUpperCase()} by ${currentSong.artistName}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                // actions
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.shuffle_rounded, size: 25),
                      Icon(Icons.repeat, size: 25),
                      Icon(Icons.share, size: 25),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 0,
                          ),
                        ),
                        child: Slider(
                          activeColor: Colors.green,
                          value: value.currentDuration.inSeconds.toDouble(),
                          min: 0,
                          max: value.totalDuration.inSeconds.toDouble(),
                          onChanged: (double time) {},
                          onChangeEnd: (double time) {
                            value.seek(Duration(seconds: time.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('00:00'),
                            Text('${value.totalDuration.inSeconds.toDouble()}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 12, 50, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.skip_previous_rounded, size: 30),
                            GestureDetector(
                              onTap: () {
                                value.pauseOrResume();
                              },
                              child:
                                  value.isPlaying
                                      ? Icon(Icons.pause, size: 60)
                                      : Icon(Icons.play_arrow, size: 60),
                            ),
                            GestureDetector(
                              onTap: () {
                                value.playNextSong();
                              },
                              child: Icon(Icons.skip_next_rounded, size: 30),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
