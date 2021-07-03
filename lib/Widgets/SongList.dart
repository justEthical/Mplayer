import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';

import '../Plugin.dart';
import 'package:taal/HomeScreen.dart';

import 'package:mime/mime.dart';
import 'package:taal/playScreenMod.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  AudioPlayer audioPlugin = AudioPlayer();
  //bool processing = true;
  double maxW;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_setter();
  }

  _setter() {
    //processing = true;
    _gettingAllMp3Files();
    // processing = false;
    // setState(() {});
    // print(processing);
  }

  @override
  Widget build(BuildContext context) {
    maxW = MediaQuery.of(context).size.width;
    return Container(
      child: _songList(context),
    );
  }

  String _fileName(String path) {
    var lst = path.split("/");
    String name = lst[lst.length - 1];
    print(name);
    print(name.length);
    return name;
  }

  Widget _songList(BuildContext context) {
    return Expanded(
        child: Container(
      //width: maxW,
      // child: !processing
      //     ? ListView.builder(
      //         itemCount:
      //             localSongList.length == null ? 0 : localSongList.length,
      //         itemBuilder: (ctx, i) {
      //           return Card(
      //               elevation: 5,
      //               child: Container(
      //                   width: maxW,
      //                   height: 100,
      //                   child: Center(
      //                       child: ClipRRect(
      //                           borderRadius: BorderRadius.circular(5),
      //                           child: _songTileBuilderNew(
      //                               localSongList[i].path, i, context)))));
      //         })
      //     : Center(
      //         child: CircularProgressIndicator(
      //           backgroundColor: Colors.black,
      //         ),
      //       ),
      child: FutureBuilder(
        future: _gettingAllMp3Files(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount:
                      localSongList.length == null ? 0 : localSongList.length,
                  itemBuilder: (ctx, i) {
                    return Card(
                        elevation: 5,
                        child: Container(
                            width: maxW,
                            height: 100,
                            child: Center(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: _songTileBuilderNew(
                                        localSongList[i].path, i, context)))));
                  });
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            );
          }
        },
      ),
    ));
  }

  Future<Uint8List> _gettingSongImage(String path) async {
    return await Plugin.songImage(path);
  }

  List<File> bfiles = List<File>();

  Future<void> _gettingAllMp3Files() async {
    if (firstRun == false) {
      firstRun = true;
      bfiles.clear();
      //List<File> audioFiles = List<File>();
      List<Directory> storageList = await _getStorageList();
      for (Directory dir in storageList) {
        _gettingAllFilesInPath(dir.path);
        print(dir.path);
      }
      localSongList = _filteringMp3Files(bfiles);
      print(localSongList.length);
    }
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
        //print(fileOrFolder.path);
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

  _songTileBuilderNew(String imgPath, int i, BuildContext context) {
    var imgData;
    return InkWell(
        onTap: () {
          currentTrackIndex = i;
          audioPlugin.stop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      //Test(localSongList[i].path)));

                      PlayScreenMod(
                        audio: localSongList[i].path,
                        img: imgData,
                        name: _fileName(localSongList[i].path),
                      )));
        },
        child: Row(
          children: [
            FutureBuilder(
                future: _gettingSongImage(imgPath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      imgData = snapshot.data;
                      return Container(
                          width: 100,
                          height: 150,
                          child: Hero(
                              tag: "$imgPath",
                              child: Image.memory(snapshot.data)));
                    } else if (!snapshot.hasData) {
                      print('No Data Present :(');
                      return Container(
                        width: 100,
                        child: Hero(
                          tag: "$imgPath",
                          child: Image.asset("lib/Song.png"),
                        ),
                      );
                    }
                  } else {
                    return Container(
                      width: 100,
                      color: Colors.blueAccent,
                    );
                  }
                }),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(_fileName(
                      localSongList[i].path,
                    )))),
          ],
        ));
  }
}
