// ignore_for_file: prefer_final_fields, unused_field

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer_app/models/song.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistProvider extends ChangeNotifier {
  // supabase client instance
  final _supabase = Supabase.instance.client;

  //playlist of songs
  List<Song> _playlist = [];

  // current playing song
  int? _currentSongIndex;

  /* Audio Player  */

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // duration
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // initially is nor playing
  bool _isPlaying = false;

  // loading state for api
  bool _isLoading = false;

  // constructor
  PlaylistProvider() {
    listenToDuration();
    fetchPlaylist();
  }

  // fetch playlist from Supabase
  Future<void> fetchPlaylist() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _supabase.from('songs').select();

      // converting List<Map<String, dynamic>> to List<Song>
      _playlist = data.map((item) => Song.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching playlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // play song
  void play() async {
    if (currentSongIndex == null) return;
    final String url = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url));
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
    if (_currentDuration.inSeconds > 2) {
      _audioPlayer.stop();
      play();
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
  bool get isLoading => _isLoading;

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
