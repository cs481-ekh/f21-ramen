import 'dart:async';
import 'package:flutter/material.dart';

// firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
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
        ),
        // body is majority of the screen
        body: Center(
          child: Column(
            children: [
              // OutlinedButton(
              //   onPressed: addUser,
              //   child: Text('Add User'),
              // ),
              // OutlinedButton(
              //   onPressed: checkUser,
              //   child: Text('Check User'),
              // ),
              OutlinedButton(
                onPressed: registerUser,
                child: Text('Register'),
              ),
              OutlinedButton(
                onPressed: signinValidUser,
                child: Text('Sign In With Valid User'),
              ),
              OutlinedButton(
                onPressed: signinInvalidUser,
                child: Text('Sign In With Invalid User'),
              ),
              OutlinedButton(
                onPressed: signOut,
                child: Text('Sign Out'),
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
