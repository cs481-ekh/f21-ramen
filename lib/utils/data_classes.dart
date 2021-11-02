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