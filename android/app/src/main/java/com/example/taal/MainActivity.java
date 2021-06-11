package com.example.taal;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.mpatric.mp3agic.ID3v2;
import com.mpatric.mp3agic.InvalidDataException;
import com.mpatric.mp3agic.Mp3File;
import com.mpatric.mp3agic.UnsupportedTagException;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import java.io.IOException;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.example.taal/albumArt";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  super.configureFlutterEngine(flutterEngine);
  //Loader.load(org.bytedeco.javacpp.opencv_java.class);
  //System.load('C:\\Android\\opencv3\\opencv\\build\\java\\x64\\opencv_java3410.dll');
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
              switch (call.method) {
                case "getBatteryLevel":
                  int batteryLevel = getBatteryLevel();      
                  if (batteryLevel != -1) {
                    result.success(batteryLevel);
                  } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null);
                  }
                  break;
                case "songImage":
                  result.success(imple((String)call.argument("filePath")));
                  break;
                  //result.success(Plugin.foundVertices((String)call.argument("filePath")));
                default:
                  result.notImplemented();
                  break;
              }
              }
        );
  }

  private byte[] songImage(String filePath) throws IOException, UnsupportedTagException, InvalidDataException{
    Mp3File mp3file = new Mp3File(filePath);
		System.out.println("Has Id3v2 tag: " + (mp3file.hasId3v2Tag()? "Yes": "No"));
		
		if(mp3file.hasId3v2Tag()) {
			ID3v2 id3v2Tag = mp3file.getId3v2Tag();
			byte[] imgdata = id3v2Tag.getAlbumImage();
      return imgdata;
		}else{
      return null;
    }

  }

  private byte[] imple(String path){
    try{
      return songImage(path);
    }catch(IOException e){
      System.out.println(e);
      return null;
    }catch(UnsupportedTagException u){
      System.out.println(u);
      return null;
    }catch(InvalidDataException i){
      System.out.println(i);
      return null;
    }
  }

  private int getBatteryLevel() {
    int batteryLevel = -1;
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
    } else {
      Intent intent = new ContextWrapper(getApplicationContext()).
          registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
      batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
          intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
    }
    return batteryLevel;
  }

}
