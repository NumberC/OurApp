import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/FirebaseDB.dart';

//Class that handles getting user information from the database
class UserDB extends FirebaseDB {
  UserDB(this.userUID) : user = getUserDocument(userUID);

  final String userUID;
  final DocumentReference user;
  static FirebaseFirestore firestoreInstance = FirebaseDB.firestoreInstance;
  static FirebaseStorage fireStorageInstance = FirebaseDB.fireStorageInstance;

  static String enumToString(myEnum) => FirebaseDB.enumToString(myEnum);

  Future<bool> isDriver() async {
    if (user == null) return false;

    bool isDriver = false;
    String isDriverStr = enumToString(userKeys.IS_DRIVER);
    await user.get().then((value) => isDriver = value.get(isDriverStr));
    return isDriver;
  }

  Future<void> createUserInfo(User user) async {
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
        firestoreInstance.collection("Users").doc(user.uid);
    await userDoc.set(basicData);
    await setCustomerID();
    //this.user = userDoc;
  }

  //TODO: include deleting Stripe accounts and reviews
  Future<void> deleteUserInfo() async {
    CollectionReference received =
        user.collection(enumToString(userCollectionKeys.RATINGS_RECEIVED));
    CollectionReference given =
        user.collection(enumToString(userCollectionKeys.RATINGS_GIVEN));
    if (received != null) {}
    if (given != null) {}
    await user.delete();
  }

  Future<String> getUserName() async {
    String name = "N/A";
    if (user == null) return null;
    String nameRef = enumToString(userKeys.NAME);
    await user.get().then((value) => name = value.get(nameRef));
    return name;
  }

  Future<QuerySnapshot> getUserRatings() async {
    String ratingsRef = enumToString(userCollectionKeys.RATINGS_GIVEN);
    return await user.collection(ratingsRef).getDocuments();
  }

  Future<void> createReview(
      DocumentReference reviewedDriver, String message, double rating) async {
    Map<String, dynamic> reviewData = {
      enumToString(reviewKeys.DRIVER): reviewedDriver,
      enumToString(reviewKeys.REVIEW): message,
      enumToString(reviewKeys.RATING): rating
    };
    await user
        .collection(enumToString(userCollectionKeys.RATINGS_GIVEN))
        .doc(reviewedDriver.id)
        .set(reviewData);
  }

  Future<void> updateUserLocation(LocationData loc) async {
    await user.update({enumToString(userKeys.LOCATION): loc});
  }

  Future<double> getAverageDriverRating() async {
    double average = 0;
    QuerySnapshot reviews = await getDriverReviews();
    reviews.docs.forEach((element) async => average += element.get("Rating"));
    if (reviews.docs.length <= 0) return 5;
    return average / reviews.docs.length;
  }

  Future<QuerySnapshot> getDriverReviews() async {
    String ratingsCol = enumToString(userCollectionKeys.RATINGS_RECEIVED);
    return await user.collection(ratingsCol).getDocuments();
  }

  Future<Map<String, dynamic>> getUserData() async {
    Map<String, dynamic> userData;
    await user.get().then((value) {
      userData = value.data();
    });
    return userData;
  }

  static DocumentReference getUserDocument(String id) {
    return firestoreInstance.collection("Users").doc(id);
  }

  DocumentReference getDocument() => this.user;

  Future<String> getUserProfilePicture() async {
    try {
      //await fireStorageInstance.getReferenceFromUrl("$id/Profile.png/")
      return await fireStorageInstance
          .ref()
          .child(userUID)
          .child("Profile.png")
          .getDownloadURL();
    } catch (Exception) {
      return null;
    }
  }

// Business With Firebase
  Future<String> getCustomerID() async {
    String id;
    String customerRef = enumToString(userKeys.CUSTOMER_ID);
    await user.get().then((value) => id = value.get(customerRef));
    return id;
  }

  Future<String> getAccountID() async {
    DocumentSnapshot snapshot = await user.get();
    String accountIDKey = enumToString(userKeys.ACCOUNT_ID);
    return snapshot.get(accountIDKey);
  }

  //TODO: better way to register new user with stripe? Also, I should not have to know the key "id" in the functions
  Future<void> setCustomerID() async {
    Map<String, dynamic> userData = await getUserData();
    Map<String, dynamic> customerData =
        await Business.makeCustomer(userData[enumToString(userKeys.EMAIL)]);
    print(customerData);
    print(customerData["id"]);
    //print(customerData.id);
    await user.update({
      enumToString(userKeys.CUSTOMER_ID): customerData["id"],
    });
  }

  Future<void> setAccountID() async {
    Map<String, dynamic> userData = await getUserData();
    Map<String, dynamic> accountData =
        await Business.makeUserDriver(userData[enumToString(userKeys.EMAIL)]);
    await user.update({
      enumToString(userKeys.ACCOUNT_ID): accountData["id"],
      enumToString(userKeys.IS_DRIVER): true,
    });
  }
}
