import 'package:ema/utils/data_classes.dart';
import 'package:ema/utils/global_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ParticipantInfoPage extends StatelessWidget {
  final Participant participant;

  const ParticipantInfoPage({Key? key, required this.participant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components
    return Scaffold(
      appBar: AppBar(title: Text('Participant')),
      // body is majority of the screen
      body: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Text(
                          participant.participantEmail,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))),
                      ),
                      Container(
                        child: Text(
                          'Surveys Taken: ${participant.numSurveys}/${participant.surveys.length}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))),
                      )
                    ]),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black))),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
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
                                        participant.surveys[index].projectId,
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
                                        '${participant.surveys[index].timeTaken.month}/${participant.surveys[index].timeTaken.day}/${participant.surveys[index].timeTaken.year} ${participant.surveys[index].timeTaken.hour}:${participant.surveys[index].timeTaken.minute}',
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
            ],
          )),
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