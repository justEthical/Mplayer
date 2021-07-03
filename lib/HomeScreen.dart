import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:minimize_app/minimize_app.dart';

import 'package:taal/Widgets/SongList.dart';

String nowPlaying;
var currentSongAlbumart;
List<File> localSongList = List<File>();
bool firstRun = false;
String currentTrackName = "TaalPlaying";
int currentTrackIndex = 0;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double maxH, maxW;
  String presentTab = "Local";
  AudioPlayer audioPlugin = AudioPlayer();
  var img;
  double _xOffset = 0;
  bool isOpen = false;

  AnimationController _controller;
  Animation<double> _drawerWidth;
  initState() {
    super.initState();
    _storagePermission();
    _controller = AnimationController(
        duration: Duration(
          milliseconds: 500,
        ),
        vsync: this);
    _drawerWidth = Tween(begin: 0.0, end: 250.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    maxH = MediaQuery.of(context).size.height;
    maxW = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () {
          MinimizeApp.minimizeApp();
        },
        child: _home());
  }

  _home() {
    return Container(
        color: Colors.white,
        height: maxH,
        width: maxW,
        child: Scaffold(
          drawer: Drawer(),
//-----------------Upper------------------------->
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 25,
              ),
//-----------------TopBar----------------------------->
              Container(
                width: maxW,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.5))
                    ]),
                child: Column(
                  children: [
                    _topBar(), //Widget for menu option serchBar and voice Search option
                    Container(
                      child: Text(
                        "$presentTab", // Current Tab Indicator
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

//------------------------------------------List of Songs---------------------->
              SongList(),
            ],
          ),
        ));
  }

  Widget _topBar() {
    return Container(
      child: Row(
        children: [
          //Drawer Button----------------------------------------
          InkWell(
            onTap: () {
              print("something");
            },
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                !isOpen ? _controller.forward() : _controller.reverse();
                isOpen = !isOpen;
                setState(() {});
                print(isOpen);
              },
            ),
          ),
          //Search Bar-------------------------------------------
          Container(
              height: 35,
              width: maxW - 100,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: EdgeInsets.only(right: maxW - 130, left: 10),
                child: Icon(
                  Icons.search,
                  color: Colors.grey.withOpacity(0.7),
                ),
              )),
          //Voice Search Button----------------------------------
          IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                print("alfjlsdjf;ljas;lfjas;ljf;lsjd;lj");
              })
        ],
      ),
    );
  }

  _storagePermission() async {
    Permission p = Permission.storage;
    bool ps = await p.isGranted;
    if (ps) {
      //_setting();
    } else {
      await p.request();
      //_setting();
    }
  }
}
