import 'package:audioplayers/audioplayers.dart';
import 'package:audiotagger/audiotagger.dart';
// import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:media_metadata_plugin/media_metadata_plugin.dart';
// import 'package:id3/id3.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';

class Mp3List extends StatefulWidget {
  String mp3List;
  Mp3List({@required this.mp3List});
  @override
  _Mp3ListState createState() => _Mp3ListState();
}

class _Mp3ListState extends State<Mp3List> {
  AudioPlayer _audioPlayer = AudioPlayer();
  final tagger = new Audiotagger();
  bool _isPlaying = false;
  String _currentTime = "00:00";
  String _finalTime = "00:00";

  Future<Map> getTagsAsMap(String path) async {
    final String filePath = path;
    final Map map = await tagger.readTagsAsMap(path: filePath);

    return map;
  }

  Map audiodata = {};
  @override
  void initState() {
    super.initState();
    getTagsAsMap(widget.mp3List);
    _audioPlayer.onAudioPositionChanged.listen((Duration changingTime) {
      setState(() {
        _currentTime = changingTime.toString().split("/")[0];
      });
    });
    _audioPlayer.onDurationChanged.listen((Duration changingTime) {
      setState(() {
        _finalTime = changingTime.toString().split("/")[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(child: Text(widget.mp3List)),
          RaisedButton(
            onPressed: () {
              if (!_isPlaying) {
                _audioPlayer.play(widget.mp3List.toString());
                setState(() {
                  _isPlaying = true;
                });
              } else {
                _audioPlayer.pause();
                setState(() {
                  _isPlaying = false;
                });
              }
            },
            child: Icon(!_isPlaying
                ? Icons.play_arrow_outlined
                : Icons.pause_circle_filled_outlined),
          ),
          RaisedButton(
            onPressed: () {
              _audioPlayer.stop();
              setState(() {
                _isPlaying = false;
              });
              print("stop");
            },
            child: Text("Stop"),
          ),
          RaisedButton(
            onPressed: () async {
              MediaMetadataPlugin.getMediaMetaData(widget.mp3List.toString())
                  .then((value) {
                print(value.album);
                print(value.trackName);
                print(value.authorName);
                print(value.mimeTYPE);
                print(value.trackDuration);
                print(value.artistName);
              });
            },
            child: Text("tap"),
          )
        ],
      )),
    );
  }
}
