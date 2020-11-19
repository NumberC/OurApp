import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/FrontEnd/Pages/HomePage.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';
import 'package:our_app/FrontEnd/Widgets/LoginPopup.dart';
import 'package:our_app/Routes.dart';
import 'package:our_app/UserProfileArgs.dart';
import 'package:our_app/main.dart';

class AppHeader extends StatelessWidget {
  final String title = "OurApp";
  Authentication auth = Authentication();

  Future<void> goToProfile(context) async {
    //await auth.logOut();
    if (auth.isUserLoggedIn()) {
      User user = auth.getUser();
      Navigator.pushNamed(
        context,
        Routes.profileRoute,
        arguments: UserProfileArgs(user.uid),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => LoginPopup().build(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.home,
          color: primaryColor,
        ),
        onPressed: () => Navigator.pushNamed(context, Routes.homeRoute),
      ),
      actions: [
        FlatButton(
          child: Icon(
            Icons.person,
            color: primaryColor,
          ),
          onPressed: () async => await goToProfile(context),
        ),
      ],
      backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
      elevation: 0,
    );
  }
}
