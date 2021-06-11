import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taal/test.dart';
//import 'package:taal/test.dart';

import 'PlayScreen.dart';
import 'Plugin.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double maxH, maxW;
  List<File> localSongList = List<File>();
  String presentTab = "Local";
  AudioPlayer audioPlugin = AudioPlayer();
  var img;

  void _setter() async {
    _gettingAllMp3Files();
  }

  initState() {
    super.initState();
    _storagePermission();
    //_setter();
  }

  @override
  Widget build(BuildContext context) {
    maxH = MediaQuery.of(context).size.height;
    maxW = MediaQuery.of(context).size.width;
    return Container(
        color: Colors.white,
        height: maxH,
        width: maxW,
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 25,
              ),

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
                    _topBar(),
                    Container(
                      child: Text(
                        "$presentTab",
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
              Container(
                  color: Colors.green,
                  child: ListView.builder(
                    itemCount: localSongList.length??0,
                    itemBuilder: (ctx, i) {
                      return Container(
                        height: 50,
                        color: Colors.blue,
                      );
                    },
                  ))
              //_songList(),
            ],
          ),
        ));
  }

  String _fileName(String path) {
    var lst = path.split("/");
    String name = lst[lst.length - 1];
    print(name);
    print(name.length);

    return name;
  }

  Widget _songList() {
    return Expanded(
      child: Container(
          width: maxW,
          //height: 100,
          //color: Colors.blue,
          child: FutureBuilder(
            future: _gettingAllMp3Files(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                    itemCount:
                        localSongList.length == null ? 0 : localSongList.length,
                    itemBuilder: (ctx, i) {
                      return Container(
                        height: 50,
                        width: maxW,
                        color: Colors.redAccent,
                      );

                      // return Card(
                      //     elevation: 5,
                      //     child: Container(
                      //       width: maxW,
                      //         child: Center(
                      //             child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(5),
                      //                 child: _imageBuilder(
                      //                     localSongList[i].path, i)))));
                    });
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                );
              }
            },
          )),
    );
  }

  Future<Uint8List> _gettingSongImage(String path) async {
    return await Plugin.songImage(path);
  }

  Widget _imageBuilder(String imgPath, int i) {
    return FutureBuilder(
      future: _gettingSongImage(imgPath),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              //Test(localSongList[i].path)));
                              PlayScreen(
                                audio: localSongList[i].path,
                                img: snapshot.data,
                              )));
                },
                child: Row(
                  children: [
                    Container(
                        width: 100,
                        //height: 150,
                        child: Hero(
                            tag: "$imgPath",
                            child: Image.memory(snapshot.data))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(_fileName(
                              localSongList[i].path,
                            )))),
                  ],
                ));
          } else if (!snapshot.hasData) {
            print("No DATA :(");
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              //Test(localSongList[i].path)));
                              PlayScreen(
                                audio: localSongList[i].path,
                                img: snapshot.data,
                              )));
                },
                child: Row(
                  children: [
                    Container(
                        width: 100,
                        child: Hero(
                            tag: imgPath, child: Image.asset("lib/Song.png"))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(_fileName(localSongList[i].path))))
                  ],
                ));
          }
        } else {
          return Container(
            width: 100,
            height: 150,
            color: Colors.red,
          );
        }
      },
    );
  }

  Widget _songList0() {
    return Container(
      width: maxW - 80,
      height: maxW / 3,
      child: PageView.builder(
          itemCount: localSongList.length == null ? 0 : localSongList.length,
          itemBuilder: (ctx, i) {
            return Container(
              width: maxW - 80,
              height: maxW / 3,
              child: Card(
                elevation: 5,
                child: Stack(
                  children: [
                    Container(),
                    Image.file(
                      localSongList[i],
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: maxW / 3 - 30,
                      child: Text(_fileName(localSongList[i].path)),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }

  List<File> bfiles = List<File>();

  Future<void> _gettingAllMp3Files() async {
    bfiles.clear();
    //List<File> audioFiles = List<File>();
    List<Directory> storageList = await _getStorageList();
    for (Directory dir in storageList) {
      _gettingAllFilesInPath(dir.path);
    }
    localSongList = _filteringMp3Files(bfiles);
    print(localSongList.length);
  }

  Future<List<Directory>> _getStorageList() async {
    List<Directory> dirList = await getExternalStorageDirectories();
    List<Directory> filterPathList = List<Directory>();
    for (Directory dir in dirList) {
      filterPathList.add(Directory(dir.path.split("Android")[0]));
    }
    return filterPathList;
  }

  void _gettingAllFilesInPath(String path) {
    Directory dir = Directory(path);
    List<FileSystemEntity> d = dir.listSync();
    for (FileSystemEntity fileOrFolder in d) {
      if (fileOrFolder is File) {
        print(fileOrFolder.path);
        bfiles.add(fileOrFolder);
      } else {
        _gettingAllFilesInPath(fileOrFolder.path);
      }
    }
  }

  List<File> _filteringMp3Files(List<File> files) {
    List<File> mp3Files = List<File>();
    for (File f in files) {
      var typ = lookupMimeType(f.path);
      var ext = typ == null ? "Yo!!!!" : typ.split("/")[0];
      //print(ext);
      if (ext == "audio") {
        mp3Files.add(f);
        print("file Added");
      }
    }
    //print(localSongList.length);
    return mp3Files;
  }

  Widget _topBar() {
    return Container(
      child: Row(
        children: [
          //Drawer Button----------------------------------------
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: null,
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
          IconButton(icon: Icon(Icons.mic), onPressed: null)
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
