import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Routes.dart';

class LoadingDriverResponse extends StatelessWidget {
  LoadingDriverResponse({this.user});
  DocumentReference user;

  Widget getDriverRequest() {
    return Container(
      child: Column(
        children: [
          Text("You have a drive request. Do you accept it?"),
          Row(
            children: [
              FlatButton(
                  onPressed: () async {
                    await FirebaseDB.acceptOrDeclineJourney(
                        await FirebaseDB.getJourney(user), false);
                  },
                  child: Text("No")),
              FlatButton(
                  onPressed: () async {
                    await FirebaseDB.acceptOrDeclineJourney(
                        await FirebaseDB.getJourney(user), true);
                  },
                  child: Text("Yes")),
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
        var userData = snapshot.data.data;
        if (userData["Journey"] == null) return Text("Nothing yet!");

        //Check if journey is pending
        return FutureBuilder(
          future: FirebaseDB.isJourneyPending(userData["Journey"]),
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
    bool isPending = snapshot.data.data["isPending"];
    if (isPending && snapshot.data.data["Driver"] == user)
      return getDriverRequest();
    if (isPending) return CircularProgressIndicator();
    return Text("Done pending!");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: FutureBuilder(
        future: FirebaseDB.getJourney(user),
        builder: (context, AsyncSnapshot<DocumentReference> journey) {
          if (!journey.hasData) return Container();
          return StreamBuilder<DocumentSnapshot>(
            stream: journey.data.snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) =>
                getDriverResponseChecks(snapshot),
          );
        },
      ),
    );
  }
}
