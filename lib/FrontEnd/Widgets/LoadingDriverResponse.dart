import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Core/JourneyDB.dart';
import 'package:our_app/Core/UserDB.dart';
import 'package:our_app/Routes.dart';

class LoadingDriverResponse extends StatelessWidget {
  LoadingDriverResponse(this.journey);
  final JourneyDB journey;
  DocumentReference user;

  Widget getDriverRequest() {
    return Container(
      child: Column(
        children: [
          Text("You have a drive request. Do you accept it?"),
          Row(
            children: [
              FlatButton(
                child: Text("No"),
                onPressed: () async {
                  await journey.acceptOrDeclineJourney(false);
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () async {
                  await journey.acceptOrDeclineJourney(true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getDriverPerspective() {
    return StreamBuilder<DocumentSnapshot>(
      stream: user.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error!");
        if (!snapshot.hasData) return Container();
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        var userData = snapshot.data.data();

        //TODO: this shouldn't be in this file
        //Check if journey is pending
        return FutureBuilder(
          initialData: false,
          future: journey.isJourneyPending(),
          builder: (context, AsyncSnapshot<bool> snap) {
            bool journeyPending = snap.data;
            if (journeyPending) return getDriverRequest();
            return Container();
          },
        );
      },
    );
  }

  Widget getDriverResponseChecks(AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasError) return Text("Error");
    if (!snapshot.hasData) return Container();
    if (snapshot.connectionState == ConnectionState.waiting)
      return CircularProgressIndicator();
    bool isPending =
        snapshot.data.data()[FirebaseDB.enumToString(journeyKeys.PENDING)];
    if (isPending &&
        snapshot.data.data()[FirebaseDB.enumToString(journeyKeys.DRIVER)] ==
            user) return getDriverRequest();
    if (isPending) return CircularProgressIndicator();
    return Text("Done pending!");
  }

  // Get widget to alert passengar of driver's arrival
  static Widget confirmJourneyEnd(Function yetToArrive, Function arrived) {
    return AlertDialog(
      content: Column(
        children: [
          Text("Your driver has arrived!"),
          FlatButton(
            onPressed: yetToArrive,
            child: Text("They haven't arrived"),
          ),
          FlatButton(
            onPressed: arrived,
            child: Text("They've arrived!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: StreamBuilder<DocumentSnapshot>(
        stream: journey.journey.snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) =>
            getDriverResponseChecks(snapshot),
      ),
    );
  }
}
