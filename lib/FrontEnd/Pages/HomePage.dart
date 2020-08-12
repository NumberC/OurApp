import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:our_app/FrontEnd/Widgets/MapWidget.dart';
import 'package:our_app/FrontEnd/Widgets/ProfileBar.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Widget getInputTxt(context, title) {
    Color primaryColor = Theme.of(context).primaryColor;
    TextTheme textTheme = Theme.of(context).textTheme;

    UnderlineInputBorder txtFieldBorder =
        UnderlineInputBorder(borderSide: BorderSide(color: primaryColor));

    return TextField(
      decoration: InputDecoration(
          hintText: title,
          hintStyle: textTheme.bodyText2,
          enabledBorder: txtFieldBorder,
          focusedBorder: txtFieldBorder,
          disabledBorder: txtFieldBorder),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    Color backgroundColor = Theme.of(context).backgroundColor;
    TextTheme textTheme = Theme.of(context).textTheme;
    MapState myMap = MapState();
    myMap.initState();

    return Scaffold(
      appBar: AppHeader().build(context),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 0.2 * MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: myMap.build(context),
            ),
            getInputTxt(context, "Store"),
            getInputTxt(context, "Address"),
            ProfileBar(name: "Michael Jackson", price: 16.50, rating: 3.4),
            ProfileBar(name: "Dummy Jackson", price: 19.50, rating: 1.2),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
