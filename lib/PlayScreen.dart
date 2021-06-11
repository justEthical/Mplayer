import "package:flutter/material.dart";
import 'package:audioplayer/audioplayer.dart';

class PlayScreen extends StatefulWidget {
  final audio;
  final img;
  final time;
  PlayScreen({this.audio, this.img, this.time});
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  double _maxW, _maxH;
  //bool playing = true;
  AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<bool> play = ValueNotifier<bool>(true);
  int min = 0;
  ValueNotifier<int> initValue = ValueNotifier(1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioPlayer.play(widget.audio);
  }

  @override
  Widget build(BuildContext context) {
    _maxH = MediaQuery.of(context).size.height;
    _maxW = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 27,
              ),
              Container(
                color: Colors.black,
                width: _maxW,
                height: _maxH - _maxH / 4 - 35,
                child: Center(
                  child: Container(
                    width: _maxW - 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(5, 10),
                              spreadRadius: 5,
                              blurRadius: 10)
                        ]),
                    child: widget.img != null
                        ? Hero(
                            tag: widget.audio,
                            child:
                                Image.memory(widget.img, fit: BoxFit.contain))
                        : Hero(
                            tag: widget.audio,
                            child: Image.asset("lib/Song.png",
                                fit: BoxFit.contain)),
                  ),
                ),
              ),
              //Expanded(child: _slider(),)
              Expanded(
                child: _palyerTimerSeeker(),
              ),
              _controllingButtons()
            ],
          )),
    );
  }

  @override
  dispose() {
    super.dispose();
    audioPlayer.stop();
  }

  _controllingButtons() {
    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 50,
                height: 50,
                //color: Colors.blue,
                child: Icon(
                  Icons.shuffle,
                  size: 30,
                )),
            FloatingActionButton(
              onPressed: () {
                if (play.value == true) {
                  audioPlayer.pause();
                  play.value = false;
                } else {
                  audioPlayer.play(widget.audio);
                  play.value = true;
                }
                setState(() {});
                //play.value = !play.value;
                //!play.value
                //  ? audioPlayer.play(widget.audio)
                //: audioPlayer.pause();
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
        divisions: audioPlayer.duration.inSeconds,
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

  _palyerTimerSeeker() {
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
                print(t);
                return _audi(t);
              } else if (audioPlayer.state == AudioPlayerState.COMPLETED) {
                initValue.value = snapshot.data.inSeconds;
                var t = timeFormater(initValue.value);
                play.value = false;
                //setState((){});
                return _audi(t);
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("$time"),
        _slider(),
        Text(
            "${audioPlayer.duration.inMinutes}:${audioPlayer.duration.inSeconds % 60}")
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
}
