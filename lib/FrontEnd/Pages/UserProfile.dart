import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:our_app/Core/FirebasDB.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:transparent_image/transparent_image.dart';

DocumentReference driver = FirebaseDB().getDriverById("UID");

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  String name = "Loading";
  String profilePic;
  double price = 18.60;
  double averageRating = 2;
  Column reviewColumn = new Column(children: <Widget>[]);
  Map<String, dynamic> driverData;

  @override
  void initState() {
    super.initState();

    asyncInit();
  }

  void asyncInit() async {
    driverData = await FirebaseDB().getDriverDataByReference(driver);
    averageRating = await FirebaseDB().getAverageDriverRating(driver);
    profilePic = await FirebaseDB().getUserProfilePicture("UID");
    await getReviewContent(
        Theme.of(context).primaryColor, Theme.of(context).accentColor);
    setState(() {
      name = driverData["Name"];
      averageRating = averageRating;
    });
  }

  void onHireBtnPressed() async {
    print("Hired!");
  }

  FlatButton getHireButton(color) {
    return FlatButton(
      onPressed: () async => onHireBtnPressed(),
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
        image: DecorationImage(
            image: NetworkImage((profilePic != null)
                ? profilePic
                : kTransparentImage.toString()),
            fit: BoxFit.fill),
      ),
    );
  }

  Widget getStarRating(double rating, color, accentColor, size) {
    return RatingBarIndicator(
      rating: rating,
      direction: Axis.horizontal,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: color,
      ),
      unratedColor: accentColor,
      itemSize: size,
    );
  }

  Future<void> getReviewContent(primaryColor, accentColor) async {
    Column newColumn = Column(children: <Widget>[]);
    await FirebaseDB()
        .getDriverReviews(driver)
        .then((value) => value.documents.forEach((element) {
              print(element.data);
              newColumn.children.add(getReview(element.data["Review"],
                  element.data["Rating"] * 1.0, primaryColor, accentColor));
            }));
    setState(() {
      reviewColumn = newColumn;
    });
  }

  Container getReview(reviewText, rating, primaryColor, accentColor) {
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
              getStarRating(rating, Colors.white, Colors.grey, 20.0),
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
      appBar: AppHeader().build(context),
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
            getStarRating(averageRating, primaryColor, accentColor, 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(name),
                Text("\$$price"),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Reviews:"),
            ),
            reviewColumn,
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
      backgroundColor: backgroundColor,
    );
  }
}
