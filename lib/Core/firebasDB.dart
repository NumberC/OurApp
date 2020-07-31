import 'package:cloud_firestore/cloud_firestore.dart';

class firebaseDB {
  final Firestore firestoreInstance = Firestore.instance;

  Firestore getInstance() {
    return firestoreInstance;
  }

  void getNearByDrivers(country, state, town) async {
    CollectionReference countryCollection =
        firestoreInstance.collection("Z- $country");
    CollectionReference localArea =
        countryCollection.document(state).collection(town);
    await localArea.getDocuments().then((value) {
      value.documents.forEach((element) {
        print(element.documentID);
        DocumentReference userRef = element.data["Reference"];
        print(userRef);
        userRef.get().then((value) => {print(value.data)});
      });
    });
  }

  void getDriverRatings() {}

  void getUserRatings() {
    //DocumentReference ref
    DocumentReference ref =
        firestoreInstance.collection("Users").document("UID");
    ref.collection("RatingsGiven").getDocuments().then((value) {
      value.documents.forEach((element) {
        print(element.documentID);
        print(element.data);
      });
    });
  }

  void getUserByReference(DocumentReference ref) {
    ref.get().then((value) {
      print(value.data);
    });
  }

  void getUserById() {}
}
