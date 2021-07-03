import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Drawer extends StatefulWidget {
  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _avatarRotationTween;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _avatarRotationTween = Tween(begin: 1, end: 0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 5 * 3,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          offset: Offset(5, 0),
          color: Colors.black,
          blurRadius: 30,
          spreadRadius: 10,
        )
      ]),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 5 * 3,
            height: 250,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                    colors: [])),
            child: RotatedBox(
              quarterTurns: _avatarRotationTween.value,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.blueAccent,
              ),
            ),
          )
        ],
      ),
    );
  }
}
