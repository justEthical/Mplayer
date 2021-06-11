import 'dart:typed_data';

import 'package:flutter/services.dart';

class Plugin {
  static const platform = const MethodChannel('com.example.taal/albumArt');

  static Future<Uint8List> songImage(String filePath) async {
    //Uint8List albumart = List<int>();
    try {
      return await platform.invokeMethod("songImage", {"filePath": filePath});
    } on PlatformException catch (e) {
      print("something went wrong $e");
      return null;
    }
  }

  static Future<String> battery() async {
    return await platform.invokeMethod("getBatteryLevel");
  }
}
