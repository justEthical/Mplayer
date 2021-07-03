import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:taal/HomeScreen.dart';
import 'package:taal/test.dart';

import 'Plugin.dart';

class PlayScreenMod extends StatefulWidget {
  final audio;
  final img;
  final time;
  final name;
  PlayScreenMod({this.name, this.audio, this.img, this.time});
  @override
  _PlayScreenModState createState() => _PlayScreenModState();
}

class _PlayScreenModState extends State<PlayScreenMod> {
  double _maxW, _maxH;
  AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<bool> play = ValueNotifier<bool>(true);
  int min = 0;
  ValueNotifier<int> initValue = ValueNotifier(1);
  @override
  void initState() {
    super.initState();
    nowPlaying = widget.audio;
    currentSongAlbumart = widget.img;
    currentTrackName = widget.name;
    audioPlayer.play(widget.audio);
    //_taalNotification();
  }

  Future<void> _taalNotification() async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1,
      channelKey: 'play',
      title: '$currentTrackName',
      body: 'taal Playing',
    ));

    AwesomeNotifications().actionStream.listen((event) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayScreenMod(
                    audio: nowPlaying,
                    img: currentSongAlbumart,
                    name: currentTrackName,
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    _maxW = MediaQuery.of(context).size.width;
    _maxH = MediaQuery.of(context).size.height;
    return WillPopScope(
        child: Scaffold(
          body: Stack(
            children: [
              currentSongAlbumart!=null?Image.memory(
                currentSongAlbumart,
                fit: BoxFit.fill,
              ):Image.asset('lib/Song.png'),
              Center(
                  child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              )),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 27,
                        ),
//--------------------------Song Name------------------------------------------>
                        Container(
                            width: _maxW,
                            height: 120,
                            child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Center(
                                    child: Text(
                                  "$currentTrackName",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                      fontSize: 30),
                                  overflow: TextOverflow.fade,
                                )))),
//-------------------------------Song Album Art-------------------------------->
                        Container(
                          color: Colors.transparent,
                          width: _maxW,
                          height: _maxH - 120 - _maxH / 4 - 35,
                          child: Center(
                            child: Container(
                              width: _maxW - 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(5, 10),
                                        spreadRadius: 5,
                                        blurRadius: 10)
                                  ]),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: currentSongAlbumart == null
                                      ? 
                                  Hero(
                                          tag: widget.audio,
                                          child: Image.asset("lib/Song.png",
                                              fit: BoxFit.contain)):
                                              Hero(
                                          tag: widget.audio,
                                          child: Image.memory(
                                              currentSongAlbumart,
                                              fit: BoxFit.contain)),
                            ),
                          ),
                        )),
//-------------------Controlling button and progress indicator----------------->
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            color: Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Expanded(child: _playerTimerSeeker()),
                              _controllingButtons(),
                            ],
                          ),
                        ))
                        //Expanded(child: _slider(),)
                        // Expanded(
                        //   child: _palyerTimerSeeker(),
                        // ),
                        // _controllingButtons()
                      ],
                    )),
              ),
            ],
          ),
        ),
        onWillPop: () {
          play.value ? _taalNotification() : null;
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        });
  }

  _controllingButtons() {
    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Shuffle Button
            Container(
                width: 50,
                height: 50,
                //color: Colors.blue,
                child: Icon(
                  Icons.shuffle,
                  size: 30,
                )),
            //Prev Button
            Container(
                width: 50,
                height: 50,
                child: IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    size: 30,
                  ),
                  onPressed: () {
                    _prevButton();
                  },
                )),
            //PlayPause Button
            FloatingActionButton(
              onPressed: () {
                if (play.value == true) {
                  audioPlayer.pause();
                  AwesomeNotifications().cancel(1);
                  play.value = false;
                } else {
                  audioPlayer.play(widget.audio);
                  play.value = true;
                  _taalNotification();
                }
                setState(() {});
              },
              child: !play.value
                  ? Icon(
                      Icons.play_arrow,
                      size: 30,
                    )
                  : Icon(
                      Icons.pause,
                      size: 30,
                    ),
            ),
            //Next Button
            Container(
                width: 50,
                height: 50,
                child: IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    size: 30,
                  ),
                  onPressed: () async {
                    _nextButton();
                  },
                )),
            //Replay Button
            Container(
                width: 50,
                height: 50,
                //color: Colors.blue,
                child: IconButton(
                  icon: Icon(
                    Icons.replay,
                  ),
                  onPressed: () {
                    audioPlayer.stop();
                    audioPlayer.play(widget.audio);
                  },
                ))
          ],
        ),
      ),
    );
  }

  _slider() {
    return Slider(
        min: 1,
        max: audioPlayer.duration.inSeconds != 0
            ? audioPlayer.duration.inSeconds * 1.0
            : 100,
        value: initValue.value != 0 ? initValue.value * 1.0 : 1,
        divisions: audioPlayer.duration.inSeconds ?? 100,
        label: "${initValue.value.round()}",
        onChanged: (newVal) {
          setState(() {
            initValue.value = newVal.toInt();
            audioPlayer.seek(newVal);
          });
        },
        semanticFormatterCallback: (double newVal) {
          return '${newVal.round()}';
        });
  }

  _playerTimerSeeker() {
    return Container(
      child: StreamBuilder(
          stream: audioPlayer.onAudioPositionChanged,
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              print("errrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
              return Container();
            } else if (snapshot.hasData) {
              if (audioPlayer.state == AudioPlayerState.PLAYING ||
                      audioPlayer.state == AudioPlayerState.PAUSED
                  //audioPlayer.state == AudioPlayerState.COMPLETED
                  ) {
                initValue.value = snapshot.data.inSeconds;
                var t = timeFormater(initValue.value);
                //print(t);
                return _audi(t);
              } else if (audioPlayer.state == AudioPlayerState.COMPLETED) {
                initValue.value = snapshot.data.inSeconds;
                var t = timeFormater(initValue.value);
                play.value = false;
                //setState((){});
                return _audi(t);
              } else {
                return Container();
              }
            } else {
              print("No Date");
              return Container();
            }
          }),
    );
  }

  _audi(String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text("$time",
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold))),
        Expanded(
          child: _slider(),
        ),
        Padding(
            padding: EdgeInsets.only(right: 30),
            child: Text(
                "${audioPlayer.duration.inMinutes}:${audioPlayer.duration.inSeconds % 60}",
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold))),
      ],
    );
  }

  var n = 59;
  timeFormater(int sec) {
    if (sec > n) {
      min++;
      n += 60;
    }
    sec -= n - 59;
    return "$min:$sec";
  }

  Future<Uint8List> _gettingSongImage(String path) async {
    return await Plugin.songImage(path);
  }

  String _fileName(String path) {
    var lst = path.split("/");
    String name = lst[lst.length - 1];
    print(name);
    print(name.length);
    return name;
  }

  void _nextButton() async {
    if (localSongList.length - 1 == currentTrackIndex) {
      print("oops list ends");
    } else {
      var songPath = localSongList[currentTrackIndex + 1].path;
      currentTrackIndex++;
      audioPlayer.stop();
      audioPlayer.play(songPath);
      currentSongAlbumart = await _gettingSongImage(songPath);
      currentTrackName = _fileName(songPath);
      setState(() {});
    }
  }

  void _prevButton() async {
    if (currentTrackIndex < 1) {
      print("oops list ends");
    } else {
      var songPath = localSongList[currentTrackIndex - 1].path;
      currentTrackIndex--;
      audioPlayer.stop();
      audioPlayer.play(songPath);
      currentSongAlbumart = await _gettingSongImage(songPath);
      currentTrackName = _fileName(songPath);
      setState(() {});
    }
  }
}
