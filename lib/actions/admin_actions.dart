import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ema/actions/login_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> createNewProject(String projectId, String projectDesc) async{

  bool doesExist = await checkProjectIdExists(projectId);
  if(doesExist){
    return "Project already exists.";
  }

  String addProject = await addProjectToDatabase(projectId, projectDesc);
  if(addProject != ""){
    return "Unable to add project $projectId to database: $addProject";
  }

  bool subscribeProject = await subscribeToProjectTopic(projectId);
  if(!subscribeProject){
    return "Unable to add project in Firebase.";
  }

  return addProject;
}


Future<String> addProjectToDatabase(String projectId, String description) {
  CollectionReference projects =
  FirebaseFirestore.instance.collection('projects');

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