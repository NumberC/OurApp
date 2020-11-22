import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Authentication.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/Core/UserDB.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:our_app/globalVars.dart' as globalVars;

//Base class on which other database classes start from
class FirebaseDB {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  final LocationLogic locationLogic = globalVars.locationLogic;
  static final Geoflutterfire geo = Geoflutterfire();

  static final userCollection = UserDB.userCollection;
  static final nearRadius = LocationLogic.nearRadius;

  //TODO: get a schema for FirebaseDB
  //TODO: if make a request, and no response, report it and keep a history of it

  static String enumToString(myEnum) {
    return myEnum.toString().split(".")[1];
  }

  static Future<void> initializeApp() async {
    await Firebase.initializeApp();

    //Listen to location stream and execute locationChange function
    globalVars.locationLogic.setOnLocation(locationChange);
  }

  //Function that's executed when location changes
  static Future<void> locationChange(LocationData locData) async {
    //If the user isn't logged in, then we can't do anything
    if (!Authentication.isUserLoggedIn()) return;

    //Get the user and change their location
    UserDB user = new UserDB(Authentication.getUser().uid);
    GeoFirePoint point = globalVars.locationLogic.getGeoFirePoint();
    user.updateLocation(point.data);
  }

  static Stream<List<DocumentSnapshot>> getClosestDriver(GeoFirePoint point) {
    String isActive = enumToString(userKeys.IS_ACTIVE);
    String isDriver = enumToString(userKeys.IS_DRIVER);
    Query activeDrivers = userCollection
        .where(isActive, isEqualTo: true)
        .where(isDriver, isEqualTo: true);

    //TODO: only the drivers
    return geo.collection(collectionRef: UserDB.userCollection).within(
          center: point,
          radius: nearRadius,
          field: enumToString(userKeys.LOCATION),
        );
  }
}
