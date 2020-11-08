import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/FirebaseDB.dart';

//Class that handles creating journeys and getting data about them through the database
class JourneyDB extends FirebaseDB {
  JourneyDB(this.journey);
  final DocumentReference journey;
  static FirebaseFirestore firestoreInstance = FirebaseDB.firestoreInstance;

  //static final firestoreInstance = FirebaseDB.firestoreInstance;
  static String enumToString(myEnum) => FirebaseDB.enumToString(myEnum);

  static Future<DocumentReference> getJourney(DocumentReference user) async {
    DocumentSnapshot userData = await user.get();
    return userData.get(enumToString(userKeys.JOURNEY));
  }

  static Future<void> createNewJourney(DocumentReference user,
      DocumentReference driver, GeoPoint pickup, GeoPoint deliver) async {
    DocumentReference journey = firestoreInstance.collection("Journeys").doc();
    await journey.set({
      enumToString(journeyKeys.CLIENT): user,
      enumToString(journeyKeys.DRIVER): driver,
      enumToString(journeyKeys.PICKUP): pickup,
      enumToString(journeyKeys.DELIVER): deliver,
      enumToString(journeyKeys.PENDING): true,
    });
    await user.update({
      enumToString(userKeys.JOURNEY): journey,
    });
    await driver.update({
      enumToString(userKeys.JOURNEY): journey,
    });
  }

  Future<void> endOfJourney() async {
    DocumentSnapshot journeyValue = await journey.get();
    Map<String, dynamic> journeyData = journeyValue.data();

    String clientKey = enumToString(journeyKeys.CLIENT);
    String driverKey = enumToString(journeyKeys.DRIVER);
    String journeyKey = enumToString(userKeys.JOURNEY);

    await journeyData[clientKey].updateData({journeyKey: null});
    await journeyData[driverKey].updateData({journeyKey: null});
    await journey.delete();
  }

  Future<void> acceptOrDeclineJourney(bool isAccepted) async {
    if (!isAccepted) return await endOfJourney();
    await journey.update({
      enumToString(journeyKeys.PENDING): !isAccepted,
      enumToString(journeyKeys.REACHED_STORE): false,
      enumToString(journeyKeys.REACHED_DESTINATION): false,
    });
  }

  Future<LocationData> getJourneyDriverLocation() async {
    DocumentSnapshot journeySnap = await journey.get();
    String driverKey = enumToString(journeyKeys.DRIVER);
    DocumentReference driver = journeySnap.get(driverKey);
    DocumentSnapshot driverSnap = await driver.get();
    return driverSnap.get(enumToString(userKeys.LOCATION));
  }

  Future<void> updateAtStore(atStore) async {
    await journey.update({
      enumToString(journeyKeys.REACHED_STORE): atStore,
    });
  }

  Future<void> updateAtDestination(atDestination) async {
    await journey.update({
      enumToString(journeyKeys.REACHED_DESTINATION): atDestination,
    });
  }

  Future<bool> isJourneyPending() async {
    DocumentSnapshot journeyData = await journey.get();
    return journeyData.get(enumToString(journeyKeys.PENDING));
  }
}
