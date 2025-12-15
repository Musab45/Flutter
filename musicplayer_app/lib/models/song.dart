import 'package:flutter/foundation.dart';

class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      songName: map['title'] ?? 'Unknown Title',
      artistName: map['artist'] ?? 'Unknown Artist',
      albumArtImagePath: map['album_cover_url'] ?? '',
      audioPath: map['song_url'] ?? '',
    );
  }
}
