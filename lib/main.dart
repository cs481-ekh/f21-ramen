import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

// local imports
import 'actions/notification_actions.dart';
import 'screens/login_screen.dart';
import 'utils/data_classes.dart';
import 'screens/user_screen.dart';
import 'screens/admin_screen.dart';

// firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final projectIdController = TextEditingController();
  final adminProjectIdController = TextEditingController();
  bool _messagerInitialized = false;
  bool _savedLogin = false;
  bool _loginInitialized = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {

    //I'm initializing this here because I'm not sure if there's a better spot for it
    //We can move it if needed but it appears to work here for now
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    //On iOS, the user needs to give permission for cloud messaging
    //On Android it's authorized automatically
    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );


    // print('User granted permission: ${settings.authorizationStatus}');
    // if (settings.authorizationStatus.toString() ==
    //     "AuthorizationStatus.authorized") {
    //   setState(() {
    //     _messagerInitialized = true;
    //   });
    // }
    // if (!_messagerInitialized) {
    //   print("Permission for messages not given!");
    // }

    if (_messagerInitialized = true) {
      //This should connect to the foreground message handler
      //FirebaseMessaging.onMessage.listen(handleForegroundMessage);

      // Trying to do this right here causes an error for some reason??
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  void checkSavedLogin() async {
    bool saved = await InternalUser.checkSavedLogin();
    if(saved) {
      String? error = await InternalUser.loginWithStoredInstance();
      if(error == null) {
        setState(() {
          _savedLogin = true;
        });
      } else {
        print("Error logging in with saved credentials!");
        print(error);
        await InternalUser.clearStoredInstance();
      }
    }
    setState(() {
      _loginInitialized = true;
    });

  }

  @override
  void initState() {
    initializeFlutterFire();
    checkSavedLogin();
    super.initState();
    setupInteractedMessage();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    projectIdController.dispose();
    adminProjectIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components

    if(_savedLogin && _loginInitialized) {
      bool isAdmin = false;
      if (InternalUser.instance()?.isAdmin == true) {
        isAdmin = true;
      }
      return MaterialApp(
        home: isAdmin
            ? AdminPage(adminProjectIdController: adminProjectIdController)
            : UserPage());
    }

    if(_loginInitialized) {
      return MaterialApp(
        home: LoginPage(
            usernameController: usernameController,
            passwordController: passwordController,
            projectIdController: projectIdController,
            adminProjectIdController: adminProjectIdController),
      );
    } else {
      return MaterialApp(

        home: Scaffold(
            body: Center(
              child: Image.asset("assets/images/logo.png")
            )
        )
      );
    }
  }
}