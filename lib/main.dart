import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //This needs to happen here, I think since it's a background handler?
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  // static FirebaseMessaging messaging = FirebaseMessaging.instance;

}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //I believe that calling Firebase.initializeApp() multiple times only ensures that
  //it's initialized before continuing. I don't think it actually re-initializes it
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  _storeMessage(message);
}

void _storeMessage(RemoteMessage message) async {
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
  final newNotif =
      '{"id":"${message.messageId}",'
      '"received":"${receivedAt}",'
      '"title":"${title}",'
      '"body":"${body}",'
      '"url":"${url}"}';
  notifs.insert(0, newNotif);

  //Limit list to 5 most recent notifications
  if(notifs.length > 5) {
    notifs.removeRange(5, notifs.length - 1);
  }

  prefs.setStringList("missedNotifs", notifs);
  print("Message handled and saved to storage!");
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

    _storeMessage(message);
  }

  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();
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

    for(final n in notifs) {
      if(messageCheck) {
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

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController projectIdController;
  final TextEditingController adminProjectIdController;

  LoginPage(
      {required this.usernameController, required this.passwordController, required this.projectIdController, required this.adminProjectIdController});

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print('Subscribing to test topic: notif_test');
          await FirebaseMessaging.instance.subscribeToTopic('notif_test');
          print('Subscription successful');
        }
        break;
      case 'unsubscribe':
        {
          print('Unsubscibing from test topic: notif_test');
          await FirebaseMessaging.instance.unsubscribeFromTopic('notif_test');
          print('Unsubscription successful');
        }
        break;
      default:
        break;
    }
  }


  CollectionReference projects = FirebaseFirestore.instance.collection('projects');

  Future<String> addSubscriberToDatabase(String projectId, String description){
    return projects
        .doc(projectId)
        .set({
      'projectId': projectId,
      'description': description,
      'dateCreated': DateTime.now()
    })
    .then((value) => "")
    .catchError((error) => error.toString());
  }

  Future<bool> subscribeToProjectTopic(String projectId){
      return FirebaseMessaging.instance.subscribeToTopic(projectId)
          .then((value) => true)
          .catchError((error) => false);
  }

  Future<bool> checkProjectIdExists(String projectId) async {

    bool check = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return true;
      } else {
        return false;
      }
    });

    return check;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.userChanges().listen((User? user) {
      if (user == null) { // TODO: if user is not logged in, navigate to login/register page
        print('Signed OUT');
      } else {
        print('Signed IN');
      }
    });

    // get reference for cloud database
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    Future<String> addUserToDatabase() async {

      return users
          .doc(usernameController.text)
          .set({
        'email': usernameController.text,
        'projectId': projectIdController.text,
        'dateCreated': DateTime.now()
      })
          .then((value) => "")
          .catchError((error) => error.toString());
    }

    Future<String> registerUser() {

      return auth
          .createUserWithEmailAndPassword(
              email: usernameController.text, password: passwordController.text)
          .then((value) => "")
          .catchError((error) => error.toString());
    }

    Future<String> addNewUser() async {

        String errorMessage = "";

        // subscribe to provided project id list
        // error checking doesn't matter here lmaaaoooo
        if(!(await checkProjectIdExists(projectIdController.text))){
          errorMessage = "Project ID does not exist.";
          return errorMessage;
        }

        // register user with authentication
        String regUser = await registerUser();
        if(regUser != ""){
            errorMessage = "Could not register new user: $regUser";
            return errorMessage;
        }

        // add user to database to save projectId and other data
        // but only if auth worked
        // TODO: do we need to handle if auth succeeded but db add failed delete account?
        String addDb = await addUserToDatabase();
        if(addDb != ""){
          errorMessage = "Could not add user to database: $addDb";
          return errorMessage;
        }

        return errorMessage;
    }


    Future<dynamic> getUsersProjectId(String username) async {

      dynamic data;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          data = documentSnapshot.get("projectId");
        } else {
          data = null;
        }
      });

      return data;
    }

    Future<String> signinUser() async {

      String errorMessage = "";

      // sign-in using auth
      try {
        await auth.signInWithEmailAndPassword(email: usernameController.text, password: passwordController.text);
      } catch (error) {
          errorMessage = error.toString();
          return errorMessage;
      }

      // get user data from firebase data for project id
      dynamic userProjectId = await getUsersProjectId(usernameController.text);
      if(userProjectId == null){
        errorMessage = "Unable to find user in database";
        return errorMessage;
      }
      //subscribe user to project
      bool subscribeCheck = await subscribeToProjectTopic(userProjectId);
      if(!subscribeCheck){
        errorMessage = "Could not subscribe user to project using ID in database.";
        return errorMessage;
      }
      else{
        subscribeToProjectTopic(projectIdController.text);
      }

      return "";

    }

    Future<void> signOut() {
      return auth.signOut();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA'),
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
            Padding(
              padding: const EdgeInsets.only(
                  top: 80.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: TextField(
                controller: usernameController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                )),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: projectIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Project ID',
                  ),
                )),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 30.0, right: 30.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: Colors.blue),
                  onPressed: () async {
                    String userExists = await signinUser();
                    // TODO: Set isAdmin if firebase username and password matches
                    // admin username and password
                    bool isAdmin = true;
                    userExists == "" // navigate to appropriate user page
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    isAdmin ? AdminPage(adminProjectIdController: adminProjectIdController) : UserPage()))
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Error"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(userExists),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                  },
                  child: const Text('Login'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: Colors.blue),
                  onPressed: () async {
                    bool isEmpty = usernameController.text == '' &&
                        passwordController.text == '';
                    RegExp exp = RegExp(r"\w+@.*\.(edu|com)");
                    bool validEmail = exp.hasMatch(usernameController.text);
                    String error = "";
                    if(validEmail){
                      error = await addNewUser();
                    }

                    isEmpty
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Empty Username or Password"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: const <Widget>[
                                      Text("The required fields are empty."),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            })
                        : validEmail
                            ? error == ""
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserPage()))
                                : showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Unable to register user."),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(error),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    })
                            : showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Email Invalid"),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: const <Widget>[
                                          Text("Not a valid email."),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                  },
                  child: const Text('Sign Up'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA'),
      ),
      // body is majority of the screen
      body: Center(
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Notifications',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue))),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: Colors.blue),
                  onPressed: () {
                    // Remove all notifications
                    // Probably can slide or tap to get rid of one notification
                    // Also chloe didn't know what the user UI should really look like
                  },
                  child: const Text('Dismiss All'),
                )),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {

  final TextEditingController adminProjectIdController;

  AdminPage(
      {required this.adminProjectIdController});

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
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
        appBar: AppBar(
          title: const Text('EMA - Administrator'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: "Home"),
              Tab(icon: Icon(Icons.cases_outlined), text: "Projects"),
            ]
          )
        ),
        // body is majority of the screen
        body: TabBarView(
    children: [
      AdminHomePage(adminProjectIdController: adminProjectIdController),
      AdminProjectPage(),
      ]
      ),
    )
    )
    );
  }
}

class AdminHomePage extends StatefulWidget {
  final TextEditingController adminProjectIdController;

  const AdminHomePage ({ Key? key, required this.adminProjectIdController }): super(key: key);

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
    return MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
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
                        DatePicker.showTimePicker(context, showTitleActions: true, showSecondsColumn: false, onConfirm: (time) {
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
                  Text('Send notification at ${_time?.hour}:${_time?.minute} on ${_selectedDay?.month}/${_selectedDay?.day}/${_selectedDay?.year}?',),
                  TextButton(onPressed: () {
                    print('Scheduled');
                  }, child:
                    const Text('Schedule'),),
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  }, child:
                  const Text('Logout'),),
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
          ),
        )
    );
  }
}

class AdminProjectPage extends StatelessWidget {

  const AdminProjectPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    // scaffold is a layout for the major Material Components
    return MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            // body is majority of the screen
            body: Center(
              child: Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 80.0, bottom: 20.0, left: 20.0, right: 20.0),
                    child: Text('Projects'),
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
          ),
        )
    );
  }
}
