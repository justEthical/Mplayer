import "package:flutter/material.dart";
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:taal/PlayScreen.dart';
import 'package:taal/playScreenMod.dart';
import 'package:taal/test.dart';
//import 'package:taal/PlayScreen.dart';
//import 'package:taal/test.dart';
import 'HomeScreen.dart';
ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);

//final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'key1',
      channelName: 'hydra',
      channelDescription: 'justEthical',
      enableLights: true,
      enableVibration: true,
      playSound: false,
      defaultColor: Colors.blue,
      ledColor: Colors.white,
    ),
    NotificationChannel(
        //icon: 'resource://drawable/res_media_icon',
        channelKey: 'play',
        channelName: 'Media player controller',
        channelDescription: 'Media player controller',
        defaultPrivacy: NotificationPrivacy.Public,
        enableVibration: false,
        enableLights: false,
        playSound: false,
        locked: true),
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class NewHome extends StatefulWidget {
  @override
  _NewHomeState createState() => _NewHomeState();
}

class _NewHomeState extends State<NewHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            color: Colors.blueGrey,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            left: isOpen.value ?MediaQuery.of(context).size.width/5 * 3:0,
            child: HomeScreen(),)
        ],
      ),
    );
  }
}

class Noti extends StatefulWidget {
  @override
  _NotiState createState() => _NotiState();
}

class _NotiState extends State<Noti> {
  //FlutterLocalNotificationsPlugin fltrNotification;

  @override
  void initState() {
    super.initState();

    //var androidInit = AndroidInitializationSettings("logo.png");
    //var iOSInit = IOSInitializationSettings();
    //var initSettings =
    //  InitializationSettings(android: androidInit, iOS: iOSInit);
    //fltrNotification = FlutterLocalNotificationsPlugin();
    //fltrNotification.initialize(initSettings,
    //  onSelectNotification: notificationSelected);
  }

  // Future _showNotification() async {
  //   var androidDetails = AndroidNotificationDetails(
  //       "channelId", "Hydra", "My first Notification",
  //       importance: Importance.max);
  //   var iOSDetails = IOSNotificationDetails();
  //   var generalNotificationDetails =
  //       NotificationDetails(android: androidDetails, iOS: iOSDetails);
  //   await fltrNotification.show(
  //       0, "tast", "task created", generalNotificationDetails);
  // }

  Future<void> notify() async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1,
      channelKey: 'key1',
      title: 'something',
      body: 'This is the body of Notification',
    ));
  }

  Future<void> notify2(ctx) async {
    await AwesomeNotifications().createNotification(
        actionButtons: [
          NotificationActionButton(
              key: "kg",
              label: "action1",
              enabled: true,
              autoCancel: true,
              buttonType: ActionButtonType.Default)
        ],
        content: NotificationContent(
          id: 2,
          channelKey: 'media_player',
          title: 'something more',
          body: "solid body",
          //notificationLayout: NotificationLayout.MediaPlayer
        ));

    AwesomeNotifications().actionStream.listen((event) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      SizedBox(
        height: 100,
      ),
      ElevatedButton(
          onPressed: () async {
            await notify2(context);
          },
          child: Text('media')),
      RaisedButton(
        onPressed: () async {
          await notify();
        },
        child: Text("Flteer"),
      ),
      ElevatedButton(
          onPressed: () {
            AwesomeNotifications().cancel(2);
          },
          child: Text("cancel"))
    ]));
  }

  //Future notificationSelected(String payload) async {}
}
