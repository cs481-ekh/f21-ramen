import 'package:ema/utils/data_classes.dart';
import 'package:ema/utils/global_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'admin_participant_info_page.dart';

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
                    signOut();
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