// lazily going to use this singleton class to hold the user object returned by Firebase auth
// plus our own user information
// instantiate this using: InternalUser.instance(user: <user>, projectId: <projectId>, isAdmin: <isAdmin>
// access the instance with InternalUser.instance() or InternalUser.instance().projectId, etc.
import 'package:firebase_auth/firebase_auth.dart';

class InternalUser {
  final User? user;
  final String? projectId;
  final bool? isAdmin;

  InternalUser({
    this.user,
    this.projectId = "",
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
  // static final InternalUser _singleton = InternalUser._internal();
  //
  // InternalUser._internal();
  //
  // factory InternalUser(var user, bool isAdmin) {
  //   _singleton.user = user;
  //   _singleton.isAdmin = isAdmin;
  //   return _singleton;
  // }

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
