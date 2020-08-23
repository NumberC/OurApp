import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Core/FirebasDB.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:transparent_image/transparent_image.dart';

FirebaseDB firebaseDB = new FirebaseDB();
Authentication auth = new Authentication();

class UserProfile extends StatefulWidget {
  UserProfile(this.uid, {this.price});
  final String uid;
  final double price;

  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  DocumentReference user;
  String name;
  String profilePic;
  double price;
  double averageRating = 2;
  bool isDriver;
  bool isSelf = false;

  @override
  void initState() {
    super.initState();

    user = firebaseDB.getUserById(widget.uid);
    price = widget.price;

    asyncInit();
  }

  void asyncInit() async {
    name = await firebaseDB.getUserNameByID(widget.uid);
    isDriver = await firebaseDB.isDriver(user);
    FirebaseUser loggedInUser = await auth.getUser();
    if (loggedInUser != null) {
      isSelf = loggedInUser.uid == widget.uid;
    }
    if (isDriver) averageRating = await firebaseDB.getAverageDriverRating(user);

    setState(() {
      averageRating = averageRating;
    });
  }

  void onHireBtnPressed() async {
    print("Hired!");
  }

  Widget getHireButton(color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: FlatButton(
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
          ),
        ),
      ],
    );
  }

  Container getProfilePicture(picURL, color) {
    double radius = 150;

    DecorationImage decImg = null;
    if (picURL != null) {
      decImg = DecorationImage(image: NetworkImage(picURL), fit: BoxFit.fill);
    }

    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        image: decImg,
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

  Widget getReviewContent(reviews, primaryColor, accentColor) {
    if (reviews.length > 0) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> review = reviews[index].data;
          return getReview(review["Review"], review["Rating"] * 1.0,
              primaryColor, accentColor);
        },
      );
    } else {
      return Text("None");
    }
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
              Text(
                reviewText,
                textAlign: TextAlign.left,
              ),
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

  Widget creditCardView(type, last4Digits) {
    Color primary = Theme.of(context).primaryColor;
    double iconSize = 15;

    return Row(
      children: [
        Icon(
          Icons.credit_card,
          color: primary,
        ),
        Text("$type Ending In $last4Digits"),
        Icon(
          Icons.edit,
          size: iconSize,
          color: primary,
        ),
      ],
    );
  }

  Widget getPayment() {
    Text title = Text("Payment:");
    double leftIndent = 30;
    double verticalPadding = 5;
    Color primary = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, verticalPadding, 0, verticalPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              title,
              GestureDetector(
                onTap: () {
                  print("It worked");
                },
                child: Icon(
                  Icons.add,
                  color: primary,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                leftIndent, verticalPadding, 0, verticalPadding),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: 2,
              itemBuilder: (context, i) {
                return creditCardView("Visa", "4523");
              },
            ),
          ),
        ],
      ),
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
            if (isSelf)
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      onPressed: () async => await auth.logOut(),
                      child: Text(
                        "Sign Out",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.arrow_left,
                  color: primaryColor,
                ),
                FutureBuilder(
                  future: firebaseDB.getUserProfilePicture(widget.uid),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    profilePic = snapshot.data;
                    return getProfilePicture(profilePic, primaryColor);
                  },
                ),
                Icon(
                  Icons.arrow_right,
                  color: primaryColor,
                ),
              ],
            ),
            if (isDriver)
              getStarRating(averageRating, primaryColor, accentColor, 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(name),
                if (price != null) Text("\$${price.toStringAsFixed(2)}"),
              ],
            ),
            if (isSelf) getPayment(),
            if (isSelf)
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Reviews Given:"),
              ),
            if (isSelf)
              FutureBuilder(
                future: firebaseDB.getUserRatings(user),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  List<DocumentSnapshot> reviews =
                      snapshot.data.documents.toList();
                  return getReviewContent(reviews, primaryColor, accentColor);
                },
              ),
            if (isDriver)
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Reviews Received:"),
              ),
            if (isDriver)
              FutureBuilder(
                future: firebaseDB.getDriverReviews(user),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  List<DocumentSnapshot> reviews =
                      snapshot.data.documents.toList();
                  return getReviewContent(reviews, primaryColor, accentColor);
                },
              ),
            if (!isSelf && isDriver) getHireButton(primaryColor),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
