import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:our_app/FrontEnd/Pages/HomePage.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';
import 'package:our_app/FrontEnd/Widgets/LoginPopup.dart';
import 'package:our_app/main.dart';

class AppHeader extends StatelessWidget {
  final String title = "OurApp";

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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        ),
      ),
      actions: [
        FlatButton(
          child: Icon(
            Icons.person,
            color: primaryColor,
          ),
          onPressed: () => {
            showDialog(
              context: context,
              builder: (context) => LoginPopup().build(context),
            ),
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfile()), //UserProfile()
            ), */
          },
        ),
      ],
      backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
      elevation: 0,
    );
  }
}
