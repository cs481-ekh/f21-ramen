// lazily going to use this singleton class to hold the user object returned by Firebase auth
// plus our own user information
// instantiate this using: InternalUser.instance(user: <user>, projectId: <projectId>, isAdmin: <isAdmin>
// access the instance with InternalUser.instance() or InternalUser.instance().projectId, etc.
import 'package:firebase_auth/firebase_auth.dart';

class InternalUser {
  User? user;
  String? projectId;
  bool isAdmin = false;

  InternalUser({
    this.user,
    this.projectId,
    this.isAdmin = false
  });

  static InternalUser? _instance;

  static InternalUser? instance({user, projectId, isAdmin}){
    if(_instance == null){
      _instance = InternalUser(user: user, projectId: projectId, isAdmin: isAdmin);
      return _instance;
    }
    return _instance;
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
