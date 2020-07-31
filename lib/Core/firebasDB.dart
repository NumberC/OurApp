import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class firebaseDB {
  final Firestore firestoreInstance = Firestore.instance;

  Firestore getInstance() {
    return firestoreInstance;
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
}
