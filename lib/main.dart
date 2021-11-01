import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

// local imports
import 'actions/notification_actions.dart';
import 'screens/login_screen.dart';

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

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    // try {
    //   // Wait for Firebase to initialize and set `_initialized` state to true
    //   await Firebase.initializeApp();
    //   setState(() {
    //     _initialized = true;
    //   });
    // } catch (e) {
    //   // Set `_error` state to true if Firebase initialization fails
    //   setState(() {
    //     _error = true;
    //   });
    // }
    //
    // if (_error) {
    //   print("Something went wrong with Firebase...");
    // } else {
    //   print("success!");
    // }
    // if (!_initialized) {
    //   print("loading...");
    // }

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
    if (settings.authorizationStatus.toString() ==
        "AuthorizationStatus.authorized") {
      setState(() {
        _messagerInitialized = true;
      });
    }
    if (!_messagerInitialized) {
      print("Permission for messages not given!");
    }

    if (_messagerInitialized = true) {
      //This should connect to the foreground message handler
      //FirebaseMessaging.onMessage.listen(handleForegroundMessage);

      // Trying to do this right here causes an error for some reason??
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
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

    return MaterialApp(
      home: LoginPage(
          usernameController: usernameController,
          passwordController: passwordController,
          projectIdController: projectIdController,
          adminProjectIdController: adminProjectIdController),
    );
  }
}

class AdminPage extends StatelessWidget {
  final TextEditingController adminProjectIdController;

  AdminPage({required this.adminProjectIdController});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.userChanges().listen((User? user) {
      if (user == null) {
        print("Signed OUT");
      } else {
        print('Signed IN');
      }
    });

    Future<void> signOut() {
      return auth.signOut();
    }

    List<ListItem> list = [];
    List<Participant> participants = [];
    List<Survey> surveys = [];

    for (var i = 0; i < 10; i++) {
      surveys.add(Survey('id', DateTime.now(), true));
    }

    for (var i = 0; i < 10; i++) {
      participants.add(Participant("email", i % 2 == 0, 10, surveys));
    }
    for (var i = 0; i < 10; i++) {
      list.add(ListItem('id', 'name', participants));
    }

    // scaffold is a layout for the major Material Components
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: const Text('EMA - Administrator'),
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.home), text: "Home"),
                Tab(icon: Icon(Icons.cases_outlined), text: "Projects"),
              ])),
          // body is majority of the screen
          body: TabBarView(children: [
            AdminHomePage(adminProjectIdController: adminProjectIdController),
            AdminProjectPage(items: list),
          ]),
        ));
  }
}

class AdminHomePage extends StatefulWidget {
  final TextEditingController adminProjectIdController;

  const AdminHomePage({Key? key, required this.adminProjectIdController})
      : super(key: key);

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDay = DateTime.now();
  DateTime? _time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.userChanges().listen((User? user) {
      if (user == null) {
        print("Signed OUT");
      } else {
        print('Signed IN');
      }
    });

    Future<void> signOut() {
      return auth.signOut();
    }

    // scaffold is a layout for the major Material Components
    return Scaffold(
      // body is majority of the screen
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: TextField(
                controller: widget.adminProjectIdController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Project ID',
                ),
              ),
            ),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
                DatePicker.showTimePicker(context,
                    showTitleActions: true,
                    showSecondsColumn: false, onConfirm: (time) {
                  setState(() {
                    _time = time;
                  });
                }, currentTime: DateTime.now());
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              rowHeight: 40.0,
            ),
            Text(
              'Send notification at ${_time?.hour}:${_time?.minute} on ${_selectedDay?.month}/${_selectedDay?.day}/${_selectedDay?.year}?',
            ),
            TextButton(
              onPressed: () {
                print('Scheduled');
              },
              child: const Text('Schedule'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
            // OutlinedButton(
            //   onPressed: addUser,
            //   child: Text('Add User'),
            // ),
            // OutlinedButton(
            //   onPressed: checkUser,
            //   child: Text('Check User'),
            // ),
          ],
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

class AdminProjectPage extends StatelessWidget {
  final List<ListItem> items;

  const AdminProjectPage({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components
    return Scaffold(
      // body is majority of the screen
      body: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminParticipantsPage(
                              participants: items[index].participants)));
                },
                child: Container(
                  height: 45.0,
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  items[index].projectId,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                ),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0))),
                              ),
                              Container(
                                child: Text(
                                  items[index].projectName,
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                ),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0))),
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              );
            }),
        // OutlinedButton(
        //   onPressed: addUser,
        //   child: Text('Add User'),
        // ),
        // OutlinedButton(
        //   onPressed: checkUser,
        //   child: Text('Check User'),
        // ),
      ),
      bottomSheet: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Logout',
                textAlign: TextAlign.center,
              ))
        ],
      )),
    );
    // floatingActionButton: const FloatingActionButton(
    //     tooltip: 'Send Reminder',
    //     child: Icon(Icons.add),
    //     onPressed: null,
    // )
  }
}

class AdminParticipantsPage extends StatelessWidget {
  final List<Participant> participants;

  const AdminParticipantsPage({Key? key, required this.participants})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components
    return Scaffold(
      // body is majority of the screen
      appBar: AppBar(title: Text('Participants')),
      body: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParticipantInfoPage(
                              participant: participants[index])));
                },
                child: Container(
                  height: 45.0,
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  participants[index].participantEmail,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                ),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0))),
                              ),
                              Container(
                                child: participants[index].takenSurvey
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : const Icon(Icons.close,
                                        color: Colors.red),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0))),
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              );
            }),
        // OutlinedButton(
        //   onPressed: addUser,
        //   child: Text('Add User'),
        // ),
        // OutlinedButton(
        //   onPressed: checkUser,
        //   child: Text('Check User'),
        // ),
      ),
      bottomSheet: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Logout',
                textAlign: TextAlign.center,
              ))
        ],
      )),
    );
    // floatingActionButton: const FloatingActionButton(
    //     tooltip: 'Send Reminder',
    //     child: Icon(Icons.add),
    //     onPressed: null,
    // ),
  }
}

class ParticipantInfoPage extends StatelessWidget {
  final Participant participant;

  const ParticipantInfoPage({Key? key, required this.participant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components
    return Scaffold(
      appBar: AppBar(title: Text('Participant')),
      // body is majority of the screen
      body: Center(
          child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      participant.participantEmail,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                  ),
                  Container(
                    child: Text(
                      'Surveys Taken: ${participant.numSurveys}/${participant.surveys.length}',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                  )
                ]),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black))),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    height: 45.0,
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    participant.surveys[index].projectId,
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                  ),
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0))),
                                ),
                                Container(
                                  child: Text(
                                    '${participant.surveys[index].timeTaken.month}/${participant.surveys[index].timeTaken.day}/${participant.surveys[index].timeTaken.year} ${participant.surveys[index].timeTaken.hour}:${participant.surveys[index].timeTaken.minute}',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                  ),
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0))),
                                )
                              ]),
                        ),
                      ],
                    ),
                  );
                }),
            // OutlinedButton(
            //   onPressed: addUser,
            //   child: Text('Add User'),
            // ),
            // OutlinedButton(
            //   onPressed: checkUser,
            //   child: Text('Check User'),
            // ),
          ),
        ],
      )),
      bottomSheet: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Logout',
                textAlign: TextAlign.center,
              ))
        ],
      )),
    );
    // floatingActionButton: const FloatingActionButton(
    //     tooltip: 'Send Reminder',
    //     child: Icon(Icons.add),
    //     onPressed: null,
    // ),
  }
}

class ListItem {
  String projectId;
  String projectName;
  List<Participant> participants;
  ListItem(this.projectId, this.projectName, this.participants);
}

class Participant {
  String participantEmail;
  bool takenSurvey;
  int numSurveys;
  List<Survey> surveys;
  Participant(
      this.participantEmail, this.takenSurvey, this.numSurveys, this.surveys);
}

class Survey {
  String projectId;
  DateTime timeTaken;
  bool taken;
  Survey(this.projectId, this.timeTaken, this.taken);
}
