import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

class ProfileBar extends StatelessWidget {
  ProfileBar({this.name, this.price, this.rating});
  final String name;
  final double price;
  final double rating;

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              ),
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
                  Text("\$$price"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
