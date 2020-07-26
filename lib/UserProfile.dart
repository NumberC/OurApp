import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  String name = "Michael Jackson";
  String price = "\$18.60";

  FlatButton getHireButton(color) {
    return FlatButton(
      onPressed: () => {
        print("Hired!"),
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(
          "Hire",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Container getProfilePicture(color) {
    double radius = 150;
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Row getStarRating(color, size) {
    Row starRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[],
    );

    for (int i = 0; i < 5; i++) {
      Icon star = Icon(
        Icons.star,
        color: color,
        size: size,
      );
      starRow.children.add(star);
    }
    return starRow;
  }

  Container getReview(reviewText, primaryColor, accentColor) {
    double margin = 10;
    double padding = 10;

    return Container(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.person,
            color: primaryColor,
          ),
          Column(
            children: <Widget>[
              getStarRating(Colors.white, 20.0),
              Text(reviewText),
            ],
          )
        ],
      ),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.fromLTRB(0, margin, 0, margin),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    Color backgroundColor = Theme.of(context).backgroundColor;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.arrow_left,
                  color: primaryColor,
                ),
                getProfilePicture(primaryColor),
                Icon(
                  Icons.arrow_right,
                  color: primaryColor,
                ),
              ],
            ),
            getStarRating(primaryColor, 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(name),
                Text(price),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Reviews:"),
            ),
            getReview("Hello there", primaryColor, accentColor),
            getReview("Hello there", primaryColor, accentColor),
            getReview("Hello there", primaryColor, accentColor),
            Row(
              children: <Widget>[
                Expanded(
                  child: getHireButton(primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
