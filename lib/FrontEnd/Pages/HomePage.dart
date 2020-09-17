import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:our_app/FrontEnd/Widgets/LoadingDriverResponse.dart';
import 'package:our_app/FrontEnd/Widgets/MapWidget.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:our_app/FrontEnd/Widgets/ProfileBar.dart';

Authentication auth = new Authentication();

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
  LocationLogic locationLogic = globalVars.locationLogic;

  @override
  void initState() {
    super.initState();

    //Loads page after getting asynchronous data
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
      userRef = FirebaseDB.getUserDocument(user.uid);
      isDriver = await FirebaseDB.isDriver(userRef);
    }
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
    if (!isDriver) return Container();
    return ToggleButtons(
      borderRadius: BorderRadius.circular(100),
      isSelected: [false, true],
      children: [Text("Off"), Text("On")],
      onPressed: (index) async {
        if (index == 1) {
          //add driver as available on database
          await FirebaseDB.addNearByDriver(userRef);
          setState(() {
            isInDriverMode = true;
          });
        }
        if (index == 0) {
          //driver is not available on database
          await FirebaseDB.removeNearByDriver(userRef);
          setState(() {
            isInDriverMode = false;
          });
        }
      },
    );
  }

  Future<Map<String, dynamic>> getDriversAndPrice() async {
    //List<DocumentReference> drivers = await firebaseDB.getNearByDrivers();
    var drivers = [];
    Map<String, double> finalMap = {};

    for (DocumentReference i in drivers) {
      String uid = i.documentID;
      Map<String, dynamic> driverData =
          await FirebaseDB.getUserData(FirebaseDB.getUserDocument(uid));
      LocationData loc = driverData["Location"];
      LocationData myLoc = locationLogic.getLocation();

      if (loc != null) {
        double distance = await LocationLogic.getDistanceBetween(myLoc, loc);
        double price = Business.getPrice(distance);
        finalMap[uid] = price;
      }
    }

    return finalMap;
  }

  Future<void> updateLocationOnJourney() async {
    LocationData loc = LocationLogic().getLocation();
    await FirebaseDB.updateUserLocation(userRef, loc);
    var journey = await FirebaseDB.getJourney(userRef);
    var journeyData = (await journey.get()).data;
    bool isAtStore =
        await LocationLogic.isAtLocation(loc, journeyData["hasReachedStore"]);
    bool isAtDestination = await LocationLogic.isAtLocation(
        loc, journeyData["hasReachedDestination"]);
    if (isAtStore) await FirebaseDB.updateAtStore(user, isAtStore);
    if (isAtDestination)
      await FirebaseDB.updateAtDestination(user, isAtDestination);
  }

  Widget displayDrivers() {
    if (isInDriverMode) return Container();
    return FutureBuilder(
      future: getDriversAndPrice(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        Map<String, dynamic> driverMap = snapshot.data;
        if (driverMap == null) return Container();
        if (driverMap.length == 0) return Container();
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: driverMap.length,
          itemBuilder: (context, index) {
            String currentKey = driverMap.keys.elementAt(index);
            return ProfileBar(uid: currentKey, price: driverMap[currentKey]);
          },
        );
      },
    );
  }

  Widget getJourneyCancelBtn() {
    if (!isInDriverMode) return Container();
    return StreamBuilder(
      stream: userRef.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        Map<String, dynamic> userData = snap.data.data;
        if (userData["Journey"] == null) return Container();
        if (userData["Journey"]["isPending"] == true) return Container();
        return FlatButton(
          child: Text("Cancel"),
          onPressed: () async {
            await FirebaseDB.endOfJourney(userData["Journey"]);
          },
        );
      },
    );
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
            if (isDriver)
              LoadingDriverResponse(user: userRef).getDriverPerspective(),
            Container(
                height: 0.2 * MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Text("hi") //MapWidget(),
                ),
            getInputTxt(context, "Store"),
            getInputTxt(context, "Address"),
            ProfileBar(uid: "2GTpGkqfrPfLglWofym3Ag1K7IU2", price: 20),
            displayDrivers(),
            getJourneyCancelBtn(),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
