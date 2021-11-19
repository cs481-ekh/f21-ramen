import 'dart:convert';
import 'package:ema/utils/global_funcs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../actions/notification_actions.dart';

/// User screen, not as separated as I'd like; lots of state management stuff,
/// so ran into issues.
/// Would like to separate out notification list into own file.
/// Other applicable methods in actions/notifications_actions.dart

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  late SharedPreferences _SharedPrefs;
  List<String> MissedNotifs = [];
  int notifAmount = 0;

  void initializeMessageHandler() async {
    FirebaseMessaging.onMessage.listen(handleForegroundNotif);
  }

  void initializeSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _SharedPrefs = prefs;
    });
    updateMissedNotifs();
  }

  void updateMissedNotifs() {
    setState(() {
      MissedNotifs = _SharedPrefs.getStringList("missedNotifs") ?? [];
    });
    setState(() {
      notifAmount = MissedNotifs.length;
    });
    print("Updated notification list!");
  }

  void handleForegroundNotif(RemoteMessage message) async {
    print('Got a notification while in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    await storeMessage(message);
    updateMissedNotifs();
  }

  //This function defines the widget built into the ListView
  Widget listViewHelper(BuildContext context, int index) {

    final notifJSON = MissedNotifs[index];
    final nObject = jsonDecode(notifJSON);

    //["id":idnumber,"received":time,"title":"Test","body":"This is a test notification","url":"test.com",]
    final dateReceived = DateTime.parse(nObject['received']);
    final notifInfo = '${nObject['title']} : ${nObject['body']}';
    final url = nObject['url'];
    final dateString = DateFormat('yyyy-MM-dd – h:mm a').format(dateReceived);

    //In order to properly access the url object, this needs to be initialized here unfortunately
    //Against everything I understand about Dart, it works so I'm not too worried
    //If you can find another way to do it let me know
    void openNotif() async {

      var newNotifList = <String>[];
      bool messageCheck = true;

      for(final n in MissedNotifs) {
        if(messageCheck) {
          final temp = jsonDecode(n);
          //Checks the message id, filters out the handled message to remove from storage
          if (temp['id'] == nObject['id']) {
            messageCheck = false;
          } else {
            newNotifList.add(n);
          }
        } else {
          //Once we've found the matching message doing unnecessary json decoding is slow
          newNotifList.add(n);
        }
      }

      _SharedPrefs.setStringList("missedNotifs", newNotifList);

      updateMissedNotifs();

      if(url != null) {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw "Could not launch $url";
        }
      }
    }

    //This part returns the actual widget, along with a pointer to the tap function
    return Card(
        child: ListTile(
          title:Text(notifInfo),
          subtitle: Text(dateString),
          onTap: openNotif,
        )
    );
  }

  @override
  void initState() {
    initializeSharedPrefs();
    initializeMessageHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    startUserAuthListener(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA'),
        // leading: IconButton(
        //     icon: const Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.of(context).popUntil((route) => route.isFirst);
        //     }),
      ),
      
      // body is majority of the screen
      body: Center(
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Notifications',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue))),
            Flexible(
                flex: 5,
                child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: ListView.builder(
                        padding: const EdgeInsets.all(5),
                        itemCount: notifAmount,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: listViewHelper))),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: Colors.blue),
                  onPressed: () {
                    _SharedPrefs.setStringList("missedNotifs", []);
                    setState(() {
                      MissedNotifs = [];
                      notifAmount = 0;
                    });
                  },
                  child: const Text('Dismiss All'),
                )),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: TextButton(
                  onPressed: () {
                    signOut();
                  },
                  child: const Text('Logout'),
                ),)
          ],
        ),
      ),
    );
  }
}
