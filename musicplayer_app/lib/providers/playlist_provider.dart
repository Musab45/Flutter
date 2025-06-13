// ignore_for_file: prefer_final_fields

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer_app/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  //playlist of songs
  final List<Song> _playlist = [
    Song(
      songName: '9',
      artistName: 'Drake',
      albumArtImagePath: 'assets/images/9.jpg',
      audioPath: 'audios/9_audio.mp3',
    ),
    Song(
      songName: 'All Eyes on Me',
      artistName: '2Pac',
      albumArtImagePath: 'assets/images/alleyesonme.jpg',
      audioPath: 'audios/alleyesonme_audio.mp3',
    ),
    Song(
      songName: 'Solo',
      artistName: 'Future',
      albumArtImagePath: 'assets/images/solo.jpg',
      audioPath: 'audios/solo_audio.mp3',
    ),
  ];

  // current playing song
  int? _currentSongIndex;

  /* Audio Player  */

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // duration
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // constructor
  PlaylistProvider() {
    listenToDuration();
  }

  // initially is nor playing
  bool _isPlaying = false;

  // play song
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop if any song is playing
    await _audioPlayer.play(AssetSource(path)); // play the current song
    _isPlaying = true;
    notifyListeners();
  }

  // pause song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume song
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  // seek
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next song
  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < playlist.length - 1) {
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  // play previous song
  void playPreviousSong() async {
    // restart song if less than 2 seconds have elapsed
    if (_currentDuration.inSeconds < 2) {
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      }
      // if first song then loop to end of playlist
      else {
        currentSongIndex = playlist.length - 1;
      }
    }
  }

  // listen to duration
  void listenToDuration() {
    // listen to total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });
    // listen to current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
      // listen for song completion
      _audioPlayer.onPlayerComplete.listen((event) {
        playNextSong();
      });
    });
  }

  // getters
  int? get currentSongIndex => _currentSongIndex;
  List<Song> get playlist => _playlist;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  // setters
  set currentSongIndex(int? newIndex) {
    // set new index
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play(); // play the new song
    }

    // update ui
    notifyListeners();
  }
}
