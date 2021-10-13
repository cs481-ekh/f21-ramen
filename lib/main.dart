import 'dart:async';
import 'package:flutter/material.dart';

// firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());

  //This needs to happen here, I think since it's a background handler?
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    App()
    // const MaterialApp( // using Material is optional but "good practice"
    //   title: 'EMA',
    //   home: AdminHome(),
    // ),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  // static FirebaseMessaging messaging = FirebaseMessaging.instance;


}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //I believe that calling Firebase.initializeApp() multiple times only ensures that
  //it's initialized before continuing. I don't think it actually re-initializes it
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  bool _messagerInitialized = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }

    if (_error) {
      print("Something went wrong with Firebase...");
    } else {
      print("success!");
    }
    if(!_initialized) {
      print("loading...");
    }

    //I'm initializing this here because I'm not sure if there's a better spot for it
    //We can move it if needed but it appears to work here for now
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    //On iOS, the user needs to give permission for cloud messaging
    //On Android it's authorized automatically
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );



    print('User granted permission: ${settings.authorizationStatus}');
    if(settings.authorizationStatus.toString() == "AuthorizationStatus.authorized") {
      setState(() {
        _messagerInitialized = true;
      });
    }
    if(!_messagerInitialized){
      print("Permission for messages not given!");
    }

    if(_messagerInitialized = true) {
      //This should connect to the foreground message handler
      FirebaseMessaging.onMessage.listen(handleForegroundMessage);

      // Trying to do this right here causes an error for some reason??
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }


  }

  //This should be called if a message is received while the app is open
  //Placeholder info for now, later this will probably send info to the notification log widget
  void handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? openingMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (openingMessage != null) {
      _handleMessage(openingMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    print("Finished setting up notification tap handler");
  }

  void _handleMessage(RemoteMessage message) async {
    print("Handling notification press");
    if (message.data['url'] != null) {
      final url = message.data['url'];
      if (await canLaunch(url)) {
        await launch(url);
      }
      else throw "Could not launch $url";
    }
  }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print(
              'Subscribing to test topic: notif_test');
          await FirebaseMessaging.instance.subscribeToTopic('notif_test');
          print(
              'Subscription successful');
        }
        break;
      case 'unsubscribe':
        {
          print(
              'Unsubscibing from test topic: notif_test');
          await FirebaseMessaging.instance.unsubscribeFromTopic('notif_test');
          print(
              'Unsubscription successful');
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.userChanges()
        .listen((User? user){
      if(user == null){
        print("Signed OUT");
      } else{
        print('Signed IN');
      }
    });

    Future<void> registerUser(){
      return auth.createUserWithEmailAndPassword(email: 'test@gmail.com', password: 'abc123')
      .then((value) => print("User registered..."))
      .catchError((error) => print(error.code));
    }

    Future<void> signinValidUser(){
      return auth.signInWithEmailAndPassword(email: "badtest@gmail.com", password: 'abc123')
          .catchError((error) => print(error.code));
    }

    Future<void> signinInvalidUser(){
      return auth.signInWithEmailAndPassword(email: "test@gmail.com", password: 'abc123')
          .catchError((error) => print(error.code));
    }

    Future<void> signOut(){
      return auth.signOut();
    }

    // scaffold is a layout for the major Material Components
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('EMA - Administrator'),
            //This is just for testing and should be removed once a system is in
            //place to subscribe devices based on users
            actions: <Widget>[
              PopupMenuButton(
                onSelected: onActionSelected,
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'subscribe',
                      child: Text('Subscribe to topic'),
                    ),
                    const PopupMenuItem(
                      value: 'unsubscribe',
                      child: Text('Unsubscribe to topic'),
                    )
                  ];
                },
              ),
            ],
          ),
          // body is majority of the screen
          body: Center(
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () {print("button pressed");},
                  child: Text('Send Notification'),
                ),
              ],
            ),
          ),
        ),
        // floatingActionButton: const FloatingActionButton(
        //     tooltip: 'Send Reminder',
        //     child: Icon(Icons.add),
        //     onPressed: null,
        // ),
    );
  }
}
