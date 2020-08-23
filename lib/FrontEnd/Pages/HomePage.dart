import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/FirebasDB.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:our_app/FrontEnd/Widgets/MapWidget.dart';
import 'package:our_app/FrontEnd/Widgets/ProfileBar.dart';

Authentication auth = new Authentication();
FirebaseDB firebaseDB = new FirebaseDB();

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

  Future<bool> isLoggedInAndDriver() async {
    FirebaseUser user = await auth.getUser();
    if (user == null) return false;

    DocumentReference userRef = firebaseDB.getUserById(user.uid);
    return await firebaseDB.isDriver(userRef);
  }

  Future<Map<String, dynamic>> getDriversAndPrice() async {
    List<DocumentReference> drivers = await FirebaseDB().getNearByDrivers();
    Map<String, double> finalMap = {};
    for (DocumentReference i in drivers) {
      String uid = i.documentID;
      Map<String, dynamic> driverData =
          await FirebaseDB().getDriverDataById(uid);
      GeoPoint loc = driverData["Location"];
      LocationData myLoc = await LocationLogic().getLocation();
      double distance = await LocationLogic().getDistanceBetweenGeo(
          GeoPoint(myLoc.latitude, myLoc.longitude), loc);
      double price = Business().getPrice(distance);
      finalMap[uid] = price;
    }
    return finalMap;
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    Color backgroundColor = Theme.of(context).backgroundColor;
    TextTheme textTheme = Theme.of(context).textTheme;
    //MapState myMap = MapState();
    //myMap.initState();

    return Scaffold(
      appBar: AppHeader().build(context),
      body: Center(
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: isLoggedInAndDriver(),
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data) {
                  return ToggleButtons(
                    borderRadius: BorderRadius.circular(100),
                    isSelected: [false, true],
                    children: [Text("Off"), Text("On")],
                    onPressed: (index) async {
                      FirebaseUser user = await auth.getUser();
                      DocumentReference userRef =
                          firebaseDB.getDriverById(user.uid);
                      if (index == 1) {
                        await firebaseDB.addNearByDriver(userRef);
                        print("nani");
                      } else if (index == 0) {
                        await firebaseDB.removeNearByDriver(userRef);
                        print("help");
                      }
                    },
                  );
                } else {
                  return Text("");
                }
              },
            ),
            Container(
                height: 0.2 * MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Text("hi") // myMap.build(context),
                ),
            getInputTxt(context, "Store"),
            getInputTxt(context, "Address"),
            FutureBuilder(
              future: getDriversAndPrice(),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                Map<String, dynamic> driverMap = snapshot.data;
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: driverMap.length,
                  itemBuilder: (context, index) {
                    String currentKey = driverMap.keys.elementAt(index);
                    return ProfileBar(
                        uid: currentKey, price: driverMap[currentKey]);
                  },
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
