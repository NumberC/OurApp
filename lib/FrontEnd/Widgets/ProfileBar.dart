import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Core/UserDB.dart';
import 'package:our_app/Routes.dart';
import 'package:our_app/UserProfileArgs.dart';

class ProfileBar extends StatefulWidget {
  ProfileBar({this.uid, this.price});

  final String uid;
  final double price;

  @override
  ProfileBarState createState() => ProfileBarState();
}

class ProfileBarState extends State<ProfileBar> {
  String uid;
  double price;

  UserDB user;
  bool isLoading = true;
  String name;
  double rating;

  @override
  void initState() {
    super.initState();

    uid = widget.uid;
    price = widget.price;
    user = UserDB(this.uid);
    asyncInit().then((value) => setState(() {
          isLoading = false;
        }));
  }

  Future<void> asyncInit() async {
    name = await user.getUserName();
    rating = await user.getAverageDriverRating();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return CircularProgressIndicator();

    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    double borderRadius = 20;

    Container profilePic = Container(
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => {
              Navigator.pushNamed(context, Routes.profileRoute,
                  arguments: UserProfileArgs(uid, price: price)),
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      profilePic,
                      Column(
                        children: [
                          Padding(padding: EdgeInsets.all(3)),
                          Text("$name"),
                          RatingBarIndicator(
                            rating: rating,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                            unratedColor: null,
                            itemSize: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text("\$${price.toStringAsFixed(2)}"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
