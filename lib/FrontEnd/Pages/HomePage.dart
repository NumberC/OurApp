import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Core/JourneyDB.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/Core/UserDB.dart';
import 'package:our_app/FrontEnd/Widgets/AppHeader.dart';
import 'package:our_app/FrontEnd/Widgets/LoadingDriverResponse.dart';
import 'package:our_app/FrontEnd/Widgets/MapWidget.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:our_app/FrontEnd/Widgets/ProfileBar.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isInDriverMode = false;
  bool isDriver = false;
  User user;
  UserDB userDB;
  bool isLoggedIn;
  bool isInJourney = false;
  JourneyDB journey;
  LocationLogic locationLogic = globalVars.locationLogic;

  //TODO: users should not be looking for other drivers while journey pending

  @override
  void initState() {
    super.initState();
    user = Authentication.getUser();
    isLoggedIn = user != null;
    userDB = isLoggedIn ? UserDB(user.uid) : null;

    //Loads page after getting asynchronous data
    asyncInit().then(
      (value) => setState(() {
        isLoading = false;
      }),
    );
  }

  Future<void> asyncInit() async {
    if (isLoggedIn) {
      isDriver = await userDB.isDriver();

      //Check if the user is on a trip/journey
      DocumentReference journeyDoc =
          await JourneyDB.getJourney(userDB.getDocument());
      if (journeyDoc != null)
        setState(() {
          journey = JourneyDB(journeyDoc);
          isInJourney = true;
        });
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

  /*
  Widget getDriverActivityToggle() {
    if (!isDriver || isInJourney) return Container();
    return ToggleButtons(
      borderRadius: BorderRadius.circular(100),
      isSelected: [false, true],
      children: [Text("Off"), Text("On")],
      onPressed: (index) async {
        if (index == 1) {
          //add driver as available on database
          if (locationLogic.getLocation() != null) {
            await FirebaseDB.addAvailableDriver(userRef);
            setState(() {
              isInDriverMode = true;
            });
          }
        }
        if (index == 0) {
          //driver is not available on database
          await FirebaseDB.removeAvailableDriver(userRef);
          setState(() {
            isInDriverMode = false;
          });
        }
      },
    );
  }
  */

  Future<Map<String, dynamic>> getDriversAndPrice() async {
    //List<DocumentReference> drivers = await firebaseDB.getNearByDrivers();
    var drivers = [];
    Map<String, double> finalMap = {};

    for (DocumentReference i in drivers) {
      String uid = i.id;
      Map<String, dynamic> driverData = await UserDB(uid).getUserData();
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

  /*
  Future<void> updateLocationOnJourney() async {
    LocationData loc = LocationLogic().getLocation();
    //await FirebaseDB.updateUserLocation(userRef, loc);
    var journey = JourneyDB(await JourneyDB.getJourney(userDB.getDocument()));
    bool isAtStore =
        await LocationLogic.isAtLocation(loc, journeyData["hasReachedStore"]);
    bool isAtDestination = await LocationLogic.isAtLocation(
        loc, journeyData["hasReachedDestination"]);
    if (isAtStore) await FirebaseDB.updateAtStore(user, isAtStore);
    if (isAtDestination)
      await FirebaseDB.updateAtDestination(user, isAtDestination);
  }
  */

  Widget displayDrivers() {
    //Driver should not have to see other drivers?
    if (isInDriverMode) return Container();

    return StreamBuilder(
      stream: FirebaseDB.getClosestDriver(locationLogic.getGeoFirePoint()),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        print("Data? ");
        print(snapshot.hasData);

        if (!snapshot.hasData) return Container();
        print(snapshot.data);
        List<DocumentSnapshot> drivers = snapshot.data;

        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            DocumentSnapshot driver = drivers.elementAt(index);
            String currentKey = driver.id;
            return ProfileBar(uid: currentKey, price: 20);
          },
        );
      },
    );
  }

  //TODO: for both drivers and passengers
  Widget getJourneyCancelBtn() {
    if (!isInDriverMode && !isInJourney) return Container();
    return StreamBuilder(
      stream: userDB.user.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        if (!snap.data.exists) return Container();
        Map<String, dynamic> userData = snap.data.data();
        DocumentReference journey = userData["Journey"];
        if (journey == null) return Container();

        // get the journey document
        return FutureBuilder(
          initialData: null,
          future: journey.get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> journeySnap) {
            if (!journeySnap.data.exists) return Container();
            DocumentSnapshot journeyData = journeySnap.data;
            //check that journey is currently not pending
            if (journeyData["isPending"] == true) return Container();
            return FlatButton(
              child: Text("Cancel"),
              onPressed: () async {
                await this.journey.endJourney();
              },
            );
          },
        );
      },
    );
  }

  //TODO: how to handle denial
  Future<void> denyDriverArrival(JourneyDB journey) async {
    print("i don't know what to do here");
  }

  Future<void> confirmDriverArrival(JourneyDB journey) async {
    await journey.endJourney();
  }

  //TODO: shouldn't be here either
  Widget reachedTracker() {
    if (!isInJourney) return Container();
    return StreamBuilder(
      stream: journey.journey.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
        if (!snap.data.exists) return Container();
        Map<String, dynamic> journeyData = snap.data.data();

        // Get keys for database referrence
        String recDest =
            FirebaseDB.enumToString(journeyKeys.REACHED_DESTINATION);
        String recStore = FirebaseDB.enumToString(journeyKeys.REACHED_STORE);

        //Check what checkpoints have they reached
        bool reachedDestination = journeyData[recDest] == true;
        bool reachedStore = journeyData[recStore] == true;

        //These messages will appear to the driver
        String storeStatus = "Reach the store";
        String destStatus = "Reach the destination";
        String completeStatus =
            "You reached the Destination, but we need the passenger's approval";

        //These messages will appear to the passenger
        if (!isDriver) {
          storeStatus = "Driver is going to the store";
          destStatus = "Driver is going to your destination";
          completeStatus = "The driver has arrived!";
        }

        //Display status
        if (reachedDestination && !isDriver) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => showDialog(
              context: context,
              builder: (context) => LoadingDriverResponse.confirmJourneyEnd(
                () async => await denyDriverArrival(journey),
                () async => await confirmDriverArrival(journey),
              ),
            ),
          );
          return Container();
        }
        if (reachedDestination) return Text(completeStatus);
        if (reachedStore) return Text(destStatus);
        return Text(storeStatus);
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
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              //getDriverActivityToggle(),
              if (isDriver)
                LoadingDriverResponse(journey).getDriverPerspective(),
              Container(
                height: 0.2 * MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Text("Hi"), //MapWidget(journey: journey),
              ),
              reachedTracker(),
              getInputTxt(context, "Store"),
              getInputTxt(context, "Address"),
              //ProfileBar(uid: "KQeRS2rZXzYUXXJMAkuv3FpgAKe2", price: 20),
              displayDrivers(),
              getJourneyCancelBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
