import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ema/utils/data_classes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseAuth auth = FirebaseAuth.instance;

// TODO: delete/manage this (was just for testing)
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

///
/// Project/subscription
///
Future<bool> subscribeToProjectTopic(String projectId) {
  return FirebaseMessaging.instance
      .subscribeToTopic(projectId)
      .then((value) => true)
      .catchError((error) => false);
}

Future<bool> checkProjectIdExists(String projectId) async {

  bool check = true;

  check = await FirebaseFirestore.instance
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

///
/// Users
///
Future<String> addNewUser(usernameController, passwordController, projectIdController) async {
  String errorMessage = "";

  // subscribe to provided project id list
  // error checking doesn't matter here lmaaaoooo
  if (!(await checkProjectIdExists(projectIdController.text))) {
    errorMessage = "Project ID does not exist.";
    return errorMessage;
  }

  // register user with authentication
  String regUser = await registerUser(usernameController.text, passwordController.text);
  if (regUser != "") {
    errorMessage = "Could not register new user: $regUser";
    return errorMessage;
  }

  // add user to database to save projectId and other data
  // but only if auth worked
  // TODO: do we need to handle if auth succeeded but db add failed -- delete account and try again?
  String addDb = await addUserToDatabase(usernameController.text, projectIdController.text);
  if (addDb != "") {
    errorMessage = "Could not add user to database: $addDb";
    return errorMessage;
  }

  // if no errors yet, instantiate user object
  var firebaseUser = FirebaseAuth.instance.currentUser;
  InternalUser.instance(user: firebaseUser, projectId: projectIdController.text, isAdmin: false);
  await InternalUser.setStoredInstance(usernameController.text, passwordController.text);

  return errorMessage;
}
Future<String> addUserToDatabase(String username, String projectId) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  return users
      .doc(username)
      .set({
    'email': username,
    'projectId': projectId,
    'is_admin': false,
    'dateCreated': DateTime.now()
  })
      .then((value) => "")
      .catchError((error) => error.toString());
}

Future<String> registerUser(String username, String password) {
  FirebaseAuth auth = FirebaseAuth.instance;
  return auth
      .createUserWithEmailAndPassword(
      email: username, password: password)
      .then((value) => "")
      .catchError((error) => error.toString());
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

Future<dynamic> getUsersAdminPriv(String username) async {
  dynamic data;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(username)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      data = documentSnapshot.get("is_admin");
    } else {
      data = null;
    }
  });

  return data;
}

Future<String> signinUser(username, password) async {
  String errorMessage = "";

  // sign-in using auth
  var authUser;
  try {
    UserCredential result = await auth.signInWithEmailAndPassword(
        email: username, password: password);
    authUser = result.user;
  } catch (error) {
    errorMessage = error.toString();
    return errorMessage;
  }

  // get user data from firebase data for project id
  // get if user is admin
  dynamic userIsAdmin = await getUsersAdminPriv(username);
  if (userIsAdmin == null) {
    errorMessage = "Unable to find user in database";
    return errorMessage;
  }

  // if not an admin, get projectId and subscribe to project
  dynamic userProjectId = "";
  if(!userIsAdmin) {
    userProjectId = await getUsersProjectId(username);
    if (userProjectId == null) {
      errorMessage = "Unable to find user in database";
      return errorMessage;
    }

    //subscribe user to project
    bool subscribeCheck = await subscribeToProjectTopic(userProjectId);
    if (!subscribeCheck) {
      errorMessage =
      "Could not subscribe user to project using ID in database.";
      return errorMessage;
    }
  }
  // if no errors, instantiate user instance
  InternalUser.instance(user: authUser, projectId: userProjectId, isAdmin: userIsAdmin);

  return "";
}