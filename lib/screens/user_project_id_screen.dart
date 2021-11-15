import 'package:ema/screens/user_screen.dart';
import 'package:ema/utils/data_classes.dart';
import 'package:ema/utils/global_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../actions/login_actions.dart';

class ProjectIdPage extends StatelessWidget {

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController projectIdController;

  ProjectIdPage(
      {Key? key, required this.usernameController,
        required this.passwordController,
        required this.projectIdController }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA')
      ),
        //This is just for testing and should be removed once a system is in
        //place to subscribe devices based on users
      // body is majority of the screen
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: projectIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Project ID',
                    ),
                  )),
            ),

                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.all(20.0),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: Colors.blue),
                      onPressed: () async {
                        String error = "";
                        error = await addNewUser(usernameController, passwordController, projectIdController);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserPage()));
                      },
                      child: const Text('Sign Up'),
                    ),
                  ),
                ])),
        );
  }
}