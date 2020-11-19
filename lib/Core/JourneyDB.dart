import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

enum journeyEndTypes { CANCELLED, FINISHED }
enum journeyKeys {
  CLIENT,
  DRIVER,
  DELIVER,
  PICKUP,
  REACHED_DESTINATION,
  REACHED_STORE,
  PENDING,
}

// String journeyClient = "Client";
// String journeyDriver = "Driver";
// String journeyDeliver = "Deliver";
// String journeyPickup = "Pickup";
// String reachedDestination = "Reached_Destination";
// String reachedStore = "Reached_Store";
// String isPending = "Is_Pending";

//Class that handles creating journeys and getting data about them through the database
class JourneyDB {
  JourneyDB(this.journey);
  final DocumentReference journey;
  static FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  //static final firestoreInstance = FirebaseDB.firestoreInstance;
  static String enumToString(myEnum) => myEnum.toString().split(".")[1];
  static CollectionReference journeyCollection =
      firestoreInstance.collection("Journeys");

  static Future<DocumentReference> getJourney(DocumentReference user) async {
    String driverKey = enumToString(journeyKeys.DRIVER);
    String clientKey = enumToString(journeyKeys.CLIENT);

    //Look for a journey where the user is either the driver or the passenger
    for (String field in [clientKey, driverKey]) {
      Query query = journeyCollection.where(field, isEqualTo: user).limit(1);
      QuerySnapshot querySnapshot = await query.get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;

      if (docs.length > 0) return docs.elementAt(0).reference;
    }
    return null;
  }

  static Future<void> createNewJourney(DocumentReference user,
      DocumentReference driver, GeoPoint pickup, GeoPoint deliver) async {
    DocumentReference journey = journeyCollection.doc();
    await journey.set({
      enumToString(journeyKeys.CLIENT): user,
      enumToString(journeyKeys.DRIVER): driver,
      enumToString(journeyKeys.PICKUP): pickup,
      enumToString(journeyKeys.DELIVER): deliver,
      enumToString(journeyKeys.PENDING): true,
    });
  }

  Future<void> endJourney() async => await journey.delete();

  Future<void> acceptOrDeclineJourney(bool isAccepted) async {
    if (!isAccepted) return await endJourney();
    await journey.update({
      enumToString(journeyKeys.PENDING): !isAccepted,
      enumToString(journeyKeys.REACHED_STORE): false,
      enumToString(journeyKeys.REACHED_DESTINATION): false,
    });
  }

  Future<DocumentReference> getDriver() async {
    DocumentSnapshot journeySnap = await journey.get();
    String driverKey = enumToString(journeyKeys.DRIVER);
    return journeySnap.get(driverKey);
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

  bool isEmpty() => journey == null;
}
