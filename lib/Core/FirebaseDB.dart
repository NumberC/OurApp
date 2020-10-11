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
enum journeyKeys {
  CLIENT,
  DELIVER,
  DRIVER,
  PICKUP,
  REACHED_DESTINATION,
  REACHED_STORE,
  PENDING
}

enum userKeys {
  EMAIL,
  NAME,
  ACCOUNT_ID,
  CUSTOMER_ID,
  JOURNEY,
  IS_DRIVER,
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

class FirebaseDB {
  static final Firestore firestoreInstance = Firestore.instance;
  static final FirebaseStorage fireStorageInstance = FirebaseStorage.instance;
  static final LocationLogic locationLogic = globalVars.locationLogic;

  static String enumToString(myEnum) {
    return myEnum.toString().split(".")[1];
  }

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
    String name = (user.displayName == null)
        ? user.email.split("@")[0]
        : user.displayName;

    var basicData = {
      //"Location": null,
      enumToString(userKeys.NAME): name,
      enumToString(userKeys.EMAIL): user.email,
      enumToString(userKeys.IS_DRIVER): false,
      enumToString(userKeys.CUSTOMER_ID): null,
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
    CollectionReference received =
        userDoc.collection(enumToString(userCollectionKeys.RATINGS_RECEIVED));
    CollectionReference given =
        userDoc.collection(enumToString(userCollectionKeys.RATINGS_GIVEN));
    if (received != null) {}
    if (given != null) {}
    await userDoc.delete();
  }

  static Future<void> createNewJourney(DocumentReference user,
      DocumentReference driver, GeoPoint pickup, GeoPoint deliver) async {
    DocumentReference journey =
        firestoreInstance.collection("Journeys").document();
    await journey.setData({
      enumToString(journeyKeys.CLIENT): user,
      enumToString(journeyKeys.DRIVER): driver,
      enumToString(journeyKeys.PICKUP): pickup,
      enumToString(journeyKeys.DELIVER): deliver,
      enumToString(journeyKeys.PENDING): true,
    });
    await user.updateData({
      enumToString(userKeys.JOURNEY): journey,
    });
    await driver.updateData({
      enumToString(userKeys.JOURNEY): journey,
    });
  }

  static Future<void> endOfJourney(DocumentReference journey) async {
    DocumentSnapshot journeyValue = await journey.get();
    Map<String, dynamic> journeyData = journeyValue.data;

    String clientKey = enumToString(journeyKeys.CLIENT);
    String driverKey = enumToString(journeyKeys.DRIVER);
    String journeyKey = enumToString(userKeys.JOURNEY);

    await journeyData[clientKey].updateData({journeyKey: null});
    await journeyData[driverKey].updateData({journeyKey: null});
    await journey.delete();
  }

  static Future<void> acceptOrDeclineJourney(
      DocumentReference journey, bool isAccepted) async {
    if (!isAccepted) return await endOfJourney(journey);
    await journey.updateData({
      enumToString(journeyKeys.PENDING): !isAccepted,
      enumToString(journeyKeys.REACHED_STORE): false,
      enumToString(journeyKeys.REACHED_DESTINATION): false,
    });
  }

  static Future<void> updateAtStore(user, atStore) async {
    var journey = await getJourney(user);
    await journey.updateData({
      enumToString(journeyKeys.REACHED_STORE): atStore,
    });
  }

  static Future<void> updateAtDestination(user, atDestination) async {
    var journey = await getJourney(user);
    await journey.updateData({
      enumToString(journeyKeys.REACHED_DESTINATION): atDestination,
    });
  }

  static Future<DocumentReference> getJourney(DocumentReference user) async {
    DocumentSnapshot userData = await user.get();
    return userData.data[enumToString(userKeys.JOURNEY)];
  }

  static Future<bool> isJourneyPending(DocumentReference journeyDoc) async {
    DocumentSnapshot journeyData = await journeyDoc.get();
    return journeyData.data[enumToString(journeyKeys.PENDING)];
  }

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
        nearbyDrivers.add(element.data["Reference"]);
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

//TODO: what is this?
  static Future<void> removeAvailableDriver(DocumentReference driver) async {
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
    String ratingsCol = enumToString(userCollectionKeys.RATINGS_RECEIVED);
    return await driver.collection(ratingsCol).getDocuments();
  }

  //Update User Info
  static Future<bool> isDriver(DocumentReference user) async {
    if (user == null) return false;

    bool isDriver = false;
    String isDriverStr = enumToString(userKeys.IS_DRIVER);
    await user.get().then((value) => isDriver = value.data[isDriverStr]);
    return isDriver;
  }

  static Future<void> createReview(DocumentReference userReviewing,
      DocumentReference reviewedDriver, String message, double rating) async {
    Map<String, dynamic> reviewData = {
      enumToString(reviewKeys.DRIVER): reviewedDriver,
      enumToString(reviewKeys.REVIEW): message,
      enumToString(reviewKeys.RATING): rating
    };
    await userReviewing
        .collection(enumToString(userCollectionKeys.RATINGS_GIVEN))
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
    if (user == null) return null;
    String nameRef = enumToString(userKeys.NAME);
    await user.get().then((value) => name = value.data[nameRef]);
    return name;
  }

  static Future<QuerySnapshot> getUserRatings(DocumentReference user) async {
    String ratingsRef = enumToString(userCollectionKeys.RATINGS_GIVEN);
    return await user.collection(ratingsRef).getDocuments();
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
    String customerRef = enumToString(userKeys.CUSTOMER_ID);
    await user.get().then((value) => id = value.data[customerRef]);
    return id;
  }

  static Future<String> getAccountID(DocumentReference driver) async {
    String id;
    String accountRef = enumToString(userKeys.ACCOUNT_ID);
    await driver.get().then((value) => id = value.data[accountRef]);
    return id;
  }

  static Future<void> setCustomerID(DocumentReference user) async {
    Map<String, dynamic> userData = await getUserData(user);
    Map<String, dynamic> customerData =
        await Business.makeCustomer(userData[enumToString(userKeys.EMAIL)]);
    print(customerData);
    print(customerData["id"]);
    //print(customerData.id);
    await user.updateData({
      enumToString(userKeys.CUSTOMER_ID): customerData["id"],
    });
  }

  static Future<void> setAccountID(DocumentReference driver) async {
    Map<String, dynamic> userData = await getUserData(driver);
    Map<String, dynamic> accountData =
        await Business.makeUserDriver(userData[enumToString(userKeys.EMAIL)]);
    await driver.updateData({
      enumToString(userKeys.ACCOUNT_ID): accountData["id"],
      enumToString(userKeys.IS_DRIVER): true,
    });
  }
}
