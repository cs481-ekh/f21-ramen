import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/user_screen.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("Handling a background message: ${message.messageId}");

  storeMessage(message);
}

Future<void> storeMessage(RemoteMessage message) async {
  //To make sure the data from a firebase message is saved, the notification's
  //info is saved to persistent storage
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> notifs = prefs.getStringList("missedNotifs") ?? <String>[];

  //A message is stored as a json string with format:
  //["id":idnumber,"received":time,"title":"Test","body":"This is a test notification","url":"test.com",]
  final title = message.notification?.title ?? "";
  final body = message.notification?.body ?? "";
  final url = message.data['url'] ?? "";
  final receivedAt = DateTime.now().toString();

  //["id":idnumber,"received":time,"title":"Test","body":"This is a test notification","url":"test.com",]
  final newNotif = '{"id":"${message.messageId}",'
      '"received":"${receivedAt}",'
      '"title":"${title}",'
      '"body":"${body}",'
      '"url":"${url}"}';
  notifs.insert(0, newNotif);

  //Limit list to 5 most recent notifications
  if(notifs.length > 5) {
    notifs.removeRange(4, notifs.length - 1);
  }

  await prefs.setStringList("missedNotifs", notifs);
  print("Message handled and saved to storage!");
}

//This should be called if a message is received while the app is open
//Placeholder info for now, later this will probably send info to the notification log widget
void handleForegroundMessage(RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }

  storeMessage(message);
}

Future<void> setupInteractedMessage() async {
  RemoteMessage? openingMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (openingMessage != null) {
    _handleMessage(openingMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  print("Finished setting up notification tap handler");
}


void _handleMessage(RemoteMessage message) async {
  print("Handling notification press");

  //New code to remove a notif from storage if it's handled
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> notifs = prefs.getStringList("missedNotifs") ?? <String>[];
  var newNotifList = <String>[];
  bool messageCheck = true;

  for (final n in notifs) {
    if (messageCheck) {
      final temp = jsonDecode(n);
      //Checks the message id, filters out the handled message to remove from storage
      if (temp['id'] == message.messageId) {
        newNotifList.add(n);
        messageCheck = false;
      }
    } else {
      //Once we've found the matching message doing unnecessary json decoding is slow
      newNotifList.add(n);
    }
  }

  prefs.setStringList("missedNotifs", newNotifList);

  if (message.data['url'] != null) {
    final url = message.data['url'];
    if (await canLaunch(url)) {
      await launch(url);
    } else
      throw "Could not launch $url";
  }
}