import 'package:ema/utils/global_funcs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/data_classes.dart';
import 'admin_home_screen.dart';
import 'admin_project_screen.dart';

class AdminPage extends StatelessWidget {
  final TextEditingController adminProjectIdController;

  AdminPage({required this.adminProjectIdController});

  @override
  Widget build(BuildContext context) {

    startUserAuthListener(context);

    List<ListItem> list = [];
    List<Participant> participants = [];
    List<Survey> surveys = [];

    for (var i = 0; i < 10; i++) {
      surveys.add(Survey('id', DateTime.now(), true));
    }

    for (var i = 0; i < 10; i++) {
      participants.add(Participant("email", i % 2 == 0, 10, surveys));
    }
    for (var i = 0; i < 10; i++) {
      list.add(ListItem('id', 'name', participants));
    }

    // scaffold is a layout for the major Material Components
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: const Text('EMA - Administrator'),
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.home), text: "Home"),
                Tab(icon: Icon(Icons.cases_outlined), text: "Projects"),
              ])),
          // body is majority of the screen
          body: TabBarView(children: [
            AdminHomePage(adminProjectIdController: adminProjectIdController),
            AdminProjectPage(items: list),
          ]),
        ));
  }
}