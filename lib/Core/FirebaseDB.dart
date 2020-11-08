import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

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

enum userKeys {
  EMAIL,
  NAME,
  ACCOUNT_ID,
  CUSTOMER_ID,
  JOURNEY,
  IS_DRIVER,
  LOCATION,
}

enum userCollectionKeys {
  RATINGS_GIVEN,
  RATINGS_RECEIVED,
}

enum reviewKeys {
  DRIVER,
  REVIEW,
  RATING,
}

//Base class on which other database classes start from
class FirebaseDB {
  static final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  static final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  static final LocationLogic locationLogic = globalVars.locationLogic;

  //TODO: get a schema for FirebaseDB
  //TODO: if make a request, and no response, report it and keep a history of it

  static String enumToString(myEnum) {
    return myEnum.toString().split(".")[1];
  }

  static Future<void> initializeApp() async => await Firebase.initializeApp();

  static Future<List<DocumentReference>> getAvailableDrivers() async {
    Address address = await locationLogic.getMyAddress();
    String country = LocationLogic.getCountryCode(address);
    String state = LocationLogic.getState(address);
    String town = LocationLogic.getTown(address);

    List<DocumentReference> nearbyDrivers = List<DocumentReference>();

    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);

    await localArea.getDocuments().then((value) {
      value.documents.forEach((element) {
        nearbyDrivers.add(element.get("Reference"));
      });
    });
    return nearbyDrivers;
  }

  static Future<void> addAvailableDriver(DocumentReference driver) async {
    LocationData location = locationLogic.getLocation();
    Address address = await locationLogic.getMyAddress();
    String country = LocationLogic.getCountryCode(address);
    String state = LocationLogic.getState(address);
    String town = LocationLogic.getTown(address);

    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);

    Map<String, dynamic> data = {
      "Location": GeoPoint(location.latitude, location.longitude),
      "Reference": driver,
    };
    await localArea.document(driver.documentID).setData(data);
  }
}
