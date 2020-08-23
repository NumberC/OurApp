import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

class FirebaseDB {
  final Firestore firestoreInstance = Firestore.instance;
  final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  LocationLogic locationLogic = new LocationLogic();

  Firestore getInstance() {
    return firestoreInstance;
  }

  void addNewUserInfo(FirebaseUser user) async {
    if (user == null) return;
    var basicData = {
      "Location": null,
      "Name": (user.displayName == null)
          ? user.email.split("@")[0]
          : user.displayName,
      "isDriver": false,
      "Payment": null,
    };
    DocumentReference userDoc =
        firestoreInstance.collection("Users").document(user.uid);
    await userDoc.setData(basicData);
  }

  Future<List<DocumentReference>> getNearByDrivers() async {
    List<String> allData = await locationLogic.getAllInfo();
    String country = allData[0];
    String state = allData[1];
    String town = allData[2];

    List<DocumentReference> nearbyDrivers = List<DocumentReference>();

    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);

    await localArea.getDocuments().then((value) {
      value.documents.forEach((element) {
        nearbyDrivers.add(element.data["Reference"]);
      });
    });
    return nearbyDrivers;
  }

  Future<void> addNearByDriver(DocumentReference driver) async {
    LocationData location = await locationLogic.getLocation();
    GeoPoint driverLoc = GeoPoint(location.latitude, location.longitude);
    List<String> allData = await locationLogic.getAllInfo();
    String country = allData[0];
    String state = allData[1];
    String town = allData[2];
    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);

    Map<String, dynamic> data = {
      "Location": driverLoc,
      "Reference": driver,
    };
    await localArea.document(driver.documentID).setData(data);
  }

  Future<void> removeNearByDriver(DocumentReference driver) async {
    List<String> allData = await locationLogic.getAllInfo();
    String country = allData[0];
    String state = allData[1];
    String town = allData[2];
    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);
    await localArea.document(driver.documentID).delete();
  }

  Future<double> getAverageDriverRating(DocumentReference driver) async {
    double average = 0;
    QuerySnapshot reviews = await getDriverReviews(driver);
    reviews.documents
        .forEach((element) async => average += element.data["Rating"]);
    return average / reviews.documents.length;
  }

  Future<QuerySnapshot> getDriverReviews(DocumentReference driver) async {
    return await driver.collection("RatingsReceived").getDocuments();
  }

  Future<Map<String, dynamic>> getDriverDataById(String id) {
    return getUserDataById(id);
  }

  Future<Map<String, dynamic>> getDriverDataByReference(
      DocumentReference driver) {
    return getUserDataByReference(driver);
  }

  DocumentReference getDriverById(String id) {
    return getUserById(id);
  }

  //Update User Info

  Future<bool> isDriver(DocumentReference user) async {
    bool isDriver = false;
    await user.get().then((value) => isDriver = value.data["isDriver"]);
    return isDriver;
  }

  Future<void> createReview(DocumentReference userReviewing,
      DocumentReference reviewedDriver, String message, double rating) async {
    Map<String, dynamic> reviewData = {
      "Driver": reviewedDriver,
      "Message": message,
      "Rating": rating
    };
    await userReviewing
        .collection("RatingsGiven")
        .document(reviewedDriver.documentID)
        .setData(reviewData);
  }

  Future<void> updateUserLocationById(String id, GeoPoint loc) async {
    await updateUserLocationByReference(getUserById(id), loc);
  }

  Future<void> updateUserLocationByReference(
      DocumentReference user, GeoPoint loc) async {
    await user.updateData({"Location": loc});
  }

  Future<void> updateUserLocation(DocumentReference userRef,
      [GeoPoint loc]) async {
    if (loc == null) {
      LocationData locData = await LocationLogic().getLocation();
      loc = new GeoPoint(locData.latitude, locData.longitude);
    }
    await userRef.updateData({"Location": loc});
  }

  //Get User Info

  Future<GeoPoint> getUserLocation(DocumentReference userRef) async {
    GeoPoint userLoc;
    await userRef.get().then((value) => userLoc = value.data["Location"]);
    return userLoc;
  }

  Future<String> getUserNameByID(String uid) async {
    return await getUserName(getUserById(uid));
  }

  Future<String> getUserName(DocumentReference user) async {
    String name = "N/A";
    await user.get().then((value) => name = value.data["Name"]);
    return name;
  }

  Future<QuerySnapshot> getUserRatings(DocumentReference user) async {
    return await user.collection("RatingsGiven").getDocuments();
  }

  Future<Map<String, dynamic>> getUserDataById(String id) async {
    return await getUserDataByReference(getUserById(id));
  }

  Future<Map<String, dynamic>> getUserDataByReference(
      DocumentReference user) async {
    Map<String, dynamic> userData;
    await user.get().then((value) {
      userData = value.data;
    });
    return userData;
  }

  DocumentReference getUserById(String id) {
    return firestoreInstance.collection("Users").document(id);
  }

  Future<String> getUserProfilePicture(String id) async {
    try {
      return await fireStorageInstance
          .ref()
          .child(id)
          .child("Profile.png")
          .getDownloadURL();
    } catch (Exception) {
      return null;
    }
  }
}
