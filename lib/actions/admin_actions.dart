import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ema/actions/login_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

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

Future<http.Response> scheduleNotification(int? minute, int? hour, int? year, int? month, int? day) {
  return http.post(
    Uri.parse('http://192.168.0.15:3000/test'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'topic': 'notif_test',
      'url': 'https://nodejs.dev/learn/get-http-request-body-data-using-nodejs',
      'title': 'Test notification',
      'message': 'It works!',
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute
    }),
  );
}