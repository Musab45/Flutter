// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:musicplayer_app/models/song.dart';
import 'package:musicplayer_app/screens/song_page.dart';
import 'package:musicplayer_app/widgets/neu_box.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer_app/providers/playlist_provider.dart';
import 'package:musicplayer_app/screens/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(Song song, int songIndex) {
    playlistProvider.currentSongIndex = songIndex;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPage(song: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PLAYLIST')),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Icon(Icons.music_note_rounded))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
              child: ListTile(
                title: Text('SETTINGS', style: TextStyle(fontSize: 18)),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          // get playlist
          final List<Song> playlist = value.playlist;
          return ListView.builder(
            // total playlist length
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              // get individual song
              final Song song = playlist[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 25),
                child: NeuBox(
                  child: ListTile(
                    title: Text(song.songName),
                    subtitle: Text(song.artistName),
                    leading: Image.asset(song.albumArtImagePath),
                    onTap: () {
                      goToSong(song, index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
