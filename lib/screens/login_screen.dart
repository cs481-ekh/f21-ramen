import 'package:ema/screens/user_project_id_screen.dart';
import 'package:ema/screens/user_screen.dart';
import 'package:ema/utils/data_classes.dart';
import 'package:ema/utils/global_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../actions/login_actions.dart';
import 'admin_screen.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController projectIdController;
  final TextEditingController adminProjectIdController;

  LoginPage({Key? key, required this.usernameController,
    required this.passwordController,
    required this.projectIdController,
    required this.adminProjectIdController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA'),
        //This is just for testing and should be removed once a system is in
        //place to subscribe devices based on users
        // actions: <Widget>[
        //   PopupMenuButton(
        //     onSelected: onActionSelected,
        //     itemBuilder: (BuildContext context) {
        //       return [
        //         const PopupMenuItem(
        //           value: 'subscribe',
        //           child: Text('Subscribe to topic'),
        //         ),
        //         const PopupMenuItem(
        //           value: 'unsubscribe',
        //           child: Text('Unsubscribe to topic'),
        //         )
        //       ];
        //     },
        //   ),
        // ],
      ),
      // body is majority of the screen
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: TextField(
                  controller: usernameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  )),
            ),
            Flexible(
                flex: 3,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 30.0, right: 30.0),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: Colors.blue),
                      onPressed: () async {
                        String userSigninCheck = await signinUser(
                            usernameController.text, passwordController.text);
                        bool isAdmin = false;
                        if (InternalUser.instance()?.isAdmin == true) {
                          isAdmin = true;
                        }
                        if (userSigninCheck == "") { // navigate to appropriate user page
                          InternalUser.setStoredInstance(usernameController.text, passwordController.text);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  isAdmin
                                      ? AdminPage(adminProjectIdController: adminProjectIdController)
                                      : UserPage()));
                        }
                        else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Error"),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(userSigninCheck),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      child: const Text('Login'),
                    ),
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
                        bool isEmpty = usernameController.text == '' &&
                            passwordController.text == '';
                        RegExp exp = RegExp(r"\w+@.*\.(edu|com)");
                        bool validEmail = exp.hasMatch(usernameController.text);
                        String error = "";
                        isEmpty
                            ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Empty Username or Password"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: const <Widget>[
                                      Text("The required fields are empty."),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            })
                            : validEmail
                            ? error == ""
                            ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProjectIdPage(
                                        usernameController: usernameController,
                                        passwordController: passwordController,
                                        projectIdController: projectIdController)))
                            : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    "Unable to register user."),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(error),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            })
                            : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Email Invalid"),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: const <Widget>[
                                      Text("Not a valid email."),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: const Text('Sign Up'),
                    ),
                  ),
                ])),
          ],
        ),
      ),
    );
  }
}
