import 'package:flutter/material.dart';
import 'package:musicplayer_app/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  //playlist of songs
  final List<Song> _playlist = [
    Song(
      songName: '9',
      artistName: 'Drake',
      albumArtImagePath: 'assets/images/9.jpg',
      audioPath: 'assets/audios/9_audio.mp3',
    ),
    Song(
      songName: 'All Eyes on Me',
      artistName: '2Pac',
      albumArtImagePath: 'assets/images/alleyesonme.jpg',
      audioPath: 'assets/audios/alleyesonme_audio.mp3',
    ),
    Song(
      songName: 'Solo',
      artistName: 'Future',
      albumArtImagePath: 'assets/images/solo.jpg',
      audioPath: 'assets/audios/solo_audio.mp3',
    ),
  ];

  // current playing song
  int? _currentSongIndex;

  // getters
  int? get currentSongIndex => _currentSongIndex;
  List<Song> get playlist => _playlist;

  // setters
  set currentSongIndex(int? songIndex) {
    // set new index
    _currentSongIndex = songIndex;

    // update ui
    notifyListeners();
  }
}
