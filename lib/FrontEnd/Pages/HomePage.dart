import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/FirebasDB.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:our_app/FrontEnd/Widgets/LoadingDriverResponse.dart';
import 'package:our_app/FrontEnd/Widgets/MapWidget.dart';
import 'package:our_app/FrontEnd/Widgets/ProfileBar.dart';

Authentication auth = new Authentication();
FirebaseDB firebaseDB = new FirebaseDB();

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isInDriverMode = false;
  bool isDriver = false;
  FirebaseUser user;
  DocumentReference userRef;
  bool isLoggedIn;
  @override
  void initState() {
    super.initState();
    asyncInit().then(
      (value) => setState(() {
        isLoading = false;
      }),
    );
  }

  Future<void> asyncInit() async {
    user = await auth.getUser();
    isLoggedIn = user != null;
    if (isLoggedIn) {
      userRef = firebaseDB.getUserById(user.uid);
      isDriver = await firebaseDB.isDriver(userRef);
    }
    print("let's go");
    print(isLoggedIn);
    print(isDriver);
  }

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

  Widget getDriverActivityToggle() {
    if (isDriver)
      return ToggleButtons(
        borderRadius: BorderRadius.circular(100),
        isSelected: [false, true],
        children: [Text("Off"), Text("On")],
        onPressed: (index) async {
          if (index == 1) {
            await firebaseDB.addNearByDriver(userRef);
            setState(() {
              isInDriverMode = true;
            });
          }
          if (index == 0) {
            await firebaseDB.removeNearByDriver(userRef);
            setState(() {
              isInDriverMode = true;
            });
          }
        },
      );
  }

  Future<Map<String, dynamic>> getDriversAndPrice() async {
    List<DocumentReference> drivers = await firebaseDB.getNearByDrivers();
    Map<String, double> finalMap = {};

    for (DocumentReference i in drivers) {
      String uid = i.documentID;
      Map<String, dynamic> driverData = await firebaseDB.getDriverDataById(uid);
      GeoPoint loc = driverData["Location"];

      LocationData myLoc = await LocationLogic().getLocation();
      if (loc != null) {
        double distance = await LocationLogic().getDistanceBetweenGeo(
            GeoPoint(myLoc.latitude, myLoc.longitude), loc);

        double price = Business.getPrice(distance);
        finalMap[uid] = price;
      }
    }

    return finalMap;
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    Color backgroundColor = Theme.of(context).backgroundColor;
    TextTheme textTheme = Theme.of(context).textTheme;

    if (isLoading)
      return Scaffold(
        appBar: AppHeader().build(context),
        body: CircularProgressIndicator(),
        backgroundColor: backgroundColor,
      );

    return Scaffold(
      appBar: AppHeader().build(context),
      body: Center(
        child: Column(
          children: <Widget>[
            getDriverActivityToggle(),
            LoadingDriverResponse(user: userRef).getDriverPerspective(),
            Container(
              height: 0.2 * MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: MapWidget(),
            ),
            getInputTxt(context, "Store"),
            getInputTxt(context, "Address"),
            ProfileBar(uid: "2GTpGkqfrPfLglWofym3Ag1K7IU2", price: 20),
            FutureBuilder(
              future: getDriversAndPrice(),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                Map<String, dynamic> driverMap = snapshot.data;
                if (driverMap == null) return Container();
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
            //TODO check if journey exists BUT is pending
            if (isDriver)
              StreamBuilder(
                stream: userRef.snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                  Map<String, dynamic> userData = snap.data.data;
                  if (userData["Journey"] == null)
                    return Text("You have no journey");
                  return FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {},
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
