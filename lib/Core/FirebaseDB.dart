import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/LocationLogic.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

enum journeyEndTypes { CANCELLED, FINISHED }

class FirebaseDB {
  static final Firestore firestoreInstance = Firestore.instance;
  static final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  static final LocationLogic locationLogic = globalVars.locationLogic;

  /*
  Users:
    UserID:
      AccountID
      CustomerID
      Email
      Journey
      Name
      isDriver
  */

  /*
  Z- Country:
    State:
      Township:
        Drivers:
          Location
          Reference
  */

  //TODO: get a schema for FirebaseDB
  //TODO: if make a request, and no response, report it and keep a history of it

  static Firestore getInstance() {
    return firestoreInstance;
  }

  static Future<void> addNewUserInfo(FirebaseUser user) async {
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
  static Future<void> deleteUserInfo(FirebaseUser user) async {
    DocumentReference userDoc =
        firestoreInstance.collection("Users").document(user.uid);
    CollectionReference received = userDoc.collection("RatingsReceived");
    CollectionReference given = userDoc.collection("RatingsGiven");
    if (received != null) {}
    if (given != null) {}
    await userDoc.delete();
  }

  static Future<void> createNewJourney(DocumentReference user,
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

  static Future<void> endOfJourney(DocumentReference journey) async {
    DocumentSnapshot journeyValue = await journey.get();
    Map<String, dynamic> journeyData = journeyValue.data;
    await journeyData["Client"].updateData({"Journey": null});
    await journeyData["Driver"].updateData({"Journey": null});
    await journey.delete();
  }

  static Future<void> acceptOrDeclineJourney(
      DocumentReference journey, bool isAccepted) async {
    if (!isAccepted) return await endOfJourney(journey);
    await journey.updateData({
      "isPending": !isAccepted,
      "hasReachedStore": false,
      "hasReachedDestination": false,
    });
  }

  static Future<void> updateAtStore(user, atStore) async {
    var journey = await getJourney(user);
    await journey.updateData({
      "hasReachedStore": atStore,
    });
  }

  static Future<void> updateAtDestination(user, atDestination) async {
    var journey = await getJourney(user);
    await journey.updateData({
      "hasReachedDestination": atDestination,
    });
  }

  static Future<DocumentReference> getJourney(DocumentReference user) async {
    DocumentSnapshot userData = await user.get();
    return userData.data["Journey"];
  }

  static Future<bool> isJourneyPending(DocumentReference journeyDoc) async {
    DocumentSnapshot journeyData = await journeyDoc.get();
    return journeyData.data["isPending"];
  }

  static Future<List<DocumentReference>> getNearByDrivers() async {
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
        nearbyDrivers.add(element.data["Reference"]);
      });
    });
    return nearbyDrivers;
  }

  static Future<void> addNearByDriver(DocumentReference driver) async {
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
      "Location": location,
      "Reference": driver,
    };
    await localArea.document(driver.documentID).setData(data);
  }

//TODO: what is this?
  static Future<void> removeNearByDriver(DocumentReference driver) async {
    Address address = await locationLogic.getMyAddress();
    String country = LocationLogic.getCountryCode(address);
    String state = LocationLogic.getState(address);
    String town = LocationLogic.getTown(address);

    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);
    await localArea.document(driver.documentID).delete();
  }

  static Future<double> getAverageDriverRating(DocumentReference driver) async {
    double average = 0;
    QuerySnapshot reviews = await getDriverReviews(driver);
    reviews.documents
        .forEach((element) async => average += element.data["Rating"]);
    if (reviews.documents.length <= 0) return 5;
    return average / reviews.documents.length;
  }

  static Future<QuerySnapshot> getDriverReviews(
      DocumentReference driver) async {
    return await driver.collection("RatingsReceived").getDocuments();
  }

  //Update User Info
  static Future<bool> isDriver(DocumentReference user) async {
    if (user == null) return false;

    bool isDriver = false;
    await user.get().then((value) => isDriver = value.data["isDriver"]);
    return isDriver;
  }

  static Future<void> createReview(DocumentReference userReviewing,
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

  static Future<void> updateUserLocation(
      DocumentReference userRef, LocationData loc) async {
    await userRef.updateData({"Location": loc});
  }

  //Get User Info
  static Future<LocationData> getUserLocation(DocumentReference userRef) async {
    LocationData userLoc;
    await userRef.get().then((value) => userLoc = value.data["Location"]);
    return userLoc;
  }

  static Future<String> getUserNameByID(String uid) async {
    return await getUserName(getUserDocument(uid));
  }

  static Future<String> getUserName(DocumentReference user) async {
    String name = "N/A";
    await user.get().then((value) => name = value.data["Name"]);
    return name;
  }

  static Future<QuerySnapshot> getUserRatings(DocumentReference user) async {
    return await user.collection("RatingsGiven").getDocuments();
  }

  static Future<Map<String, dynamic>> getUserData(
      DocumentReference user) async {
    Map<String, dynamic> userData;
    await user.get().then((value) {
      userData = value.data;
    });
    return userData;
  }

  static DocumentReference getUserDocument(String id) {
    return firestoreInstance.collection("Users").document(id);
  }

  static Future<String> getUserProfilePicture(String id) async {
    try {
      //await fireStorageInstance.getReferenceFromUrl("$id/Profile.png/")
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
  static Future<String> getCustomerID(DocumentReference user) async {
    String id;
    await user.get().then((value) => id = value.data["CustomerID"]);
    return id;
  }

  static Future<String> getAccountID(DocumentReference driver) async {
    String id;
    await driver.get().then((value) => id = value.data["AccountID"]);
    return id;
  }

  static Future<void> setCustomerID(DocumentReference user) async {
    Map<String, dynamic> userData = await getUserData(user);
    Map<String, dynamic> customerData =
        await Business.makeCustomer(userData["Email"]);
    print(customerData);
    print(customerData["id"]);
    //print(customerData.id);
    await user.updateData({
      "CustomerID": customerData["id"],
    });
  }

  static Future<void> setAccountID(DocumentReference driver) async {
    Map<String, dynamic> userData = await getUserData(driver);
    Map<String, dynamic> accountData =
        await Business.makeUserDriver(userData["Email"]);
    await driver.updateData({
      "AccountID": accountData["id"],
      "isDriver": true,
    });
  }
}
