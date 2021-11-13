import 'package:ema/actions/admin_actions.dart';
import 'package:ema/actions/login_actions.dart';
import 'package:ema/utils/data_classes.dart';
import 'package:ema/utils/global_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'admin_participants_page.dart';

class AdminProjectPage extends StatelessWidget {
  final List<ListItem> items;

  final projectIdController = TextEditingController();
  final projectDescController = TextEditingController();

  AdminProjectPage({Key? key, required this.items}) : super(key: key);
  // final formGlobalKey = GlobalKey < FormState > ();

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
      ),
      bottomSheet: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Create New Project"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                      AddProjectForm(projectIdController: projectIdController, projectDescController: projectDescController)
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Submit'),
                                onPressed: () async {
                                  if(projectIdController.text.isNotEmpty && projectDescController.text.isNotEmpty){
                                    String? projectCreated = await createNewProject(projectIdController.text, projectDescController.text);
                                    if(projectCreated != null && projectCreated != ""){
                                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                                        content: Text(projectCreated),
                                      ));
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                                        content: Text('Created project with ID: '+ projectIdController.text),
                                      ));
                                    }
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text("Cannot create project: 1 or more fields are empty."),
                                    ));
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                    Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  },
                  child: const Padding(
                  padding: EdgeInsets.only(
                      top: 20.0, bottom: 100.0, left: 20.0, right: 20.0),
                  child: Text(
                    'Create New Project',
                    textAlign: TextAlign.center,
                  )),
              )
            ],
          )),
    );
  }
}

class AddProjectForm extends StatelessWidget {

  final TextEditingController projectIdController;
  final TextEditingController projectDescController;

  const AddProjectForm(
      {Key? key, required this.projectIdController,
        required this.projectDescController}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Column (
        children: [
          const Padding(
            padding: EdgeInsets.only(
                bottom: 20.0
            ),
          ),
          TextField(
            controller: projectIdController,
            obscureText: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Project ID',
            )
          ),
          const Padding(
            padding: EdgeInsets.only(
                bottom: 20.0
            ),
          ),
          TextField(
              maxLines: 5,
              controller: projectDescController,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project Description',
              )
          )
        ]
    );
  }}