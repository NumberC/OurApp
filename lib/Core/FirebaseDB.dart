import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/JourneyDB.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/Core/UserDB.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

//Base class on which other database classes start from
class FirebaseDB {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  final LocationLogic locationLogic = globalVars.locationLogic;
  final Geoflutterfire geo = Geoflutterfire();

  final userCollection = UserDB.userCollection;
  final nearRadius = LocationLogic.nearRadius;

  //TODO: get a schema for FirebaseDB
  //TODO: if make a request, and no response, report it and keep a history of it

  static String enumToString(myEnum) {
    return myEnum.toString().split(".")[1];
  }

  static Future<void> initializeApp() async => await Firebase.initializeApp();

  void getClosestDriver(GeoFirePoint point) {
    String isActive = enumToString(userKeys.IS_ACTIVE);
    Query activeDrivers = userCollection.where(isActive, isEqualTo: true);

    geo.collection(collectionRef: activeDrivers).within(
          center: point,
          radius: nearRadius,
          field: enumToString(userKeys.LOCATION),
        );
  }
}
