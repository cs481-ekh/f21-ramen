import 'package:ema/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data_classes.dart';

// this listens to any changes in the user's Firebase authentication state
Future<void> startUserAuthListener(context) async {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final projectIdController = TextEditingController();
  final adminProjectIdController = TextEditingController();

  FirebaseAuth.instance.userChanges().listen((User? user) {

    // TODO: commented out stuff was supposed to keep regular users from being able to access the admin page (which they shouldn't be doing anyways)
    // and is  a little out of scope

    // bool isAdminPage = false;
    // if(context.toString().contains("AdminPage")){ // god this is lazy, but...
    //   isAdminPage = true;
    // }
    //
    if (user == null) {
      // TODO; need to name routes, better navigation, and clean-up navigation when it occurs

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
          LoginPage(
              usernameController: usernameController,
              passwordController: passwordController,
              projectIdController: projectIdController,
              adminProjectIdController: adminProjectIdController)));
    }
    // } else if (InternalUser.instance()?.isAdmin == false && isAdminPage){
    //   print("NO PERMISSIONS, context == $context.toString()");
    //
    //   signOut();
    //
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage(
    //       usernameController: usernameController,
    //       passwordController: passwordController,
    //       projectIdController: projectIdController,
    //       adminProjectIdController: adminProjectIdController)));
    // }
  });
}

// triggers sign out for above listener
Future<void> signOut() {
  clearInternalUser();
  InternalUser.clearStoredInstance();
  return FirebaseAuth.instance.signOut();
}
