import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

class FirebaseDB {
  final Firestore firestoreInstance = Firestore.instance;
  final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;

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

  Future<List<DocumentReference>> getNearByDrivers(country, state, town) async {
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

  //Get User Info

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
