import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

class FirebaseDB {
  final Firestore firestoreInstance = Firestore.instance;
  final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  LocationLogic locationLogic = new LocationLogic();

  Firestore getInstance() {
    return firestoreInstance;
  }

  Future<void> addNewUserInfo(FirebaseUser user) async {
    if (user == null) return;
    var basicData = {
      "Location": null,
      "Name": (user.displayName == null)
          ? user.email.split("@")[0]
          : user.displayName,
      "Email": user.email,
      "isDriver": false,
      "CustomerID": null,
    };
    DocumentReference userDoc =
        firestoreInstance.collection("Users").document(user.uid);
    await userDoc.setData(basicData);
    await setCustomerID(userDoc);
  }

  //TODO: include deleting Stripe accounts
  Future<void> deleteUserInfo(FirebaseUser user) async {
    DocumentReference userDoc =
        firestoreInstance.collection("Users").document(user.uid);
    CollectionReference received = userDoc.collection("RatingsReceived");
    CollectionReference given = userDoc.collection("RatingsGiven");
    if (received != null) {}
    if (given != null) {}
    await userDoc.delete();
  }

  Future<void> createNewJourney(DocumentReference user,
      DocumentReference driver, GeoPoint pickup, GeoPoint deliver) async {
    DocumentReference journey =
        firestoreInstance.collection("Journeys").document();
    await journey.setData({
      "Client": user,
      "Driver": driver,
      "Pickup": pickup,
      "Deliver": deliver,
      "isPending": true,
    });
    await user.updateData({
      "Journey": journey,
    });
    await driver.updateData({
      "Journey": journey,
    });
  }

  Future<void> endOfJourney(DocumentReference journey) async {
    DocumentSnapshot journeyValue = await journey.get();
    Map<String, dynamic> journeyData = journeyValue.data;
    await journeyData["Client"].updateData({"Journey": null});
    await journeyData["Driver"].updateData({"Journey": null});
    await journey.delete();
  }

  Future<DocumentReference> getJourney(DocumentReference user) async {
    DocumentSnapshot userData = await user.get();
    user.snapshots().listen((event) {
      if (event.data["Journey"] == "Pending") {
        //do something
      } else if (event.data["Journey"] == "Accepted") {
        //do something
      }
    });
    return userData.data["Journey"];
  }

  Future<bool> isJourneyPending(DocumentReference journeyDoc) async {
    DocumentSnapshot journeyData = await journeyDoc.get();
    return journeyData.data["isPending"];
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
    if (reviews.documents.length <= 0) return 5;
    return average / reviews.documents.length;
  }

  Future<QuerySnapshot> getDriverReviews(DocumentReference driver) async {
    return await driver.collection("RatingsReceived").getDocuments();
  }

  Future<Map<String, dynamic>> getDriverDataById(String id) async {
    return await getUserDataByReference(getUserById(id));
  }

  Future<Map<String, dynamic>> getDriverDataByReference(
      DocumentReference driver) {
    return getUserDataByReference(driver);
  }

  //Update User Info
  Future<bool> isDriver(DocumentReference user) async {
    if (user == null) return false;

    bool isDriver = false;
    await user.get().then((value) => isDriver = value.data["isDriver"]);
    return isDriver;
  }

  Future<void> createReview(DocumentReference userReviewing,
      DocumentReference reviewedDriver, String message, double rating) async {
    Map<String, dynamic> reviewData = {
      "Driver": reviewedDriver,
      "Review": message,
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

// Business With Firebase
  Future<String> getCustomerID(DocumentReference user) async {
    String id;
    await user.get().then((value) => id = value.data["CustomerID"]);
    return id;
  }

  Future<String> getAccountID(DocumentReference driver) async {
    String id;
    await driver.get().then((value) => id = value.data["AccountID"]);
    return id;
  }

  Future<void> setCustomerID(DocumentReference user) async {
    Map<String, dynamic> userData = await getUserDataByReference(user);
    Map<String, dynamic> customerData =
        await Business.makeCustomer(userData["Email"]);
    print(customerData);
    print(customerData["id"]);
    //print(customerData.id);
    await user.updateData({
      "CustomerID": customerData["id"],
    });
  }

  Future<void> setAccountID(DocumentReference driver) async {
    Map<String, dynamic> userData = await getUserDataByReference(driver);
    Map<String, dynamic> accountData =
        await Business.makeUserDriver(userData["Email"]);
    await driver.updateData({
      "AccountID": accountData["id"],
      "isDriver": true,
    });
  }
}
