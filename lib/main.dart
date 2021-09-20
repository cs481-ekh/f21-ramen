import 'dart:async';
import 'package:flutter/material.dart';

// firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }

    if(_error){
      print("Something went wrong with Firebase...");
    }
    else{
      print("success!");
    }
    if(!_initialized){
      print("loading...");
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('EMA - Administrator'),
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
          // floatingActionButton: const FloatingActionButton(
          //     tooltip: 'Send Reminder',
          //     child: Icon(Icons.add),
          //     onPressed: null,
          // ),
        ),
    );
  }
}
