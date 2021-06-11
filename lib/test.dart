import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  final song;
  Test(this.song);
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  int min = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<int> initValue = ValueNotifier(1);

  @override
  void initState() {
    super.initState();
    audioPlayer.play(widget.song);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
      ),
      body: Column(
        children: [
          //_slider(),
          Container(
            child: StreamBuilder(
                stream: audioPlayer.onAudioPositionChanged,
                builder: (ctx, snapshot) {
                  if (snapshot.hasError) {
                    print("errrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
                    return Container();
                  } else if (snapshot.hasData) {
                    if (audioPlayer.state == AudioPlayerState.PLAYING) {
                      initValue.value = snapshot.data.inSeconds;
                      var t = timeFormater(initValue.value);
                      print(t);
                      return _audi(t);
                    }
                  } else {
                    print("No Date");
                    return Container();
                  }
                }),
          )
        ],
      ),
    );
  }

  _slider() {
    return Slider(
        min: 1,
        max: audioPlayer.duration.inSeconds !=null?audioPlayer.duration.inSeconds * 1.0:100,
        value: 1,
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

  _audi(String time) {
    return Row(
      children: [_slider(), Text("$time")],
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
