import 'dart:async';
import 'package:flutter/material.dart';

// firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App()
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
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
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
    if (!_initialized) {
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

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot querySnapshot){
    //     for (var element in querySnapshot.docs) {print(element["firstName"]); }
    // });

    Future<void> checkUser() {
      return users.where('email', isEqualTo: 'test@gmail.com').get().then((value) => {for (var element in value.docs) {print(element["firstName"])}  }).catchError((error) => print("Failed to get user."));
    }

    Future<void> addUser() {
      return users
          .add({
            'firstName': "Dana",
            'lastName': "Default",
            'email': "test2@gmail.com",
            'projectId': 124,
            'dateCreated': '10-03-2021'
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user."));
    }

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
                onPressed: addUser,
                child: Text('Add User'),
              ),
              OutlinedButton(
                onPressed: checkUser,
                child: Text('Check User'),
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
