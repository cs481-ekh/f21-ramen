// lazily going to use this singleton class to hold the user object returned by Firebase auth
// plus our own user information
// instantiate this using: InternalUser.instance(user: <user>, projectId: <projectId>, isAdmin: <isAdmin>
// access the instance with InternalUser.instance() or InternalUser.instance().projectId, etc.
import 'package:ema/actions/login_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InternalUser {
  User? user;
  String? projectId;
  bool isAdmin = false;

  InternalUser({
    this.user,
    this.projectId,
    this.isAdmin = false
  });

  //This actually works now, but the clearInstance method is not called properly in many cases
  static InternalUser? _instance;

  static InternalUser? instance({user, projectId, isAdmin}){
    if(_instance == null){
      _instance = InternalUser(user: user, projectId: projectId, isAdmin: isAdmin);
      return _instance;
    }
    if(_instance!.user == null) {
      _instance!.user = user;
      _instance!.projectId = projectId;
      _instance!.isAdmin = isAdmin;
    }
    return _instance;
  }

  //This gets the user information stored with FlutterSecureStore *and* logs in with that info
  static Future<String?> loginWithStoredInstance() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
    String userName = allValues['user'] ?? '';
    String password = allValues['password'] ?? '';

    if(userName != '') {
      String errorMessage = await signinUser(userName, password);
      if(errorMessage!= "") return errorMessage;
    }
  }

  //Checks stored user info, but doesn't do anything with it
  static Future<bool> checkSavedLogin() async {
    final storage = new FlutterSecureStorage();
    String user = await storage.read(key: 'user') ?? '';
    if(user != '') return true;
    else return false;
  }

  //This wipes the stored user information, but not the InternalUser instance
  //Both this method and clearInternalUser should be called when logging out
  static clearStoredInstance() async {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();
  }

  //Sets the stored login data, should be called after successful login
  static setStoredInstance(username, password) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'user', value: username);
    await storage.write(key: 'password', value: password);
  }
}

// for cleaning up user object upon exit or sign-out
Future<void> clearInternalUser() async {
  InternalUser? internalUser = InternalUser.instance();

  if(internalUser != null){
    internalUser.user = null;
    internalUser.projectId = null;
    internalUser.isAdmin = false;
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
