import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  FirebaseAuth firebaseInstance = FirebaseAuth.instance;

  Future<bool> isUserLoggedIn() async {
    return await firebaseInstance.currentUser() != null;
  }

  void registerEmailPass(email, pass) async {
    try {
      await firebaseInstance.createUserWithEmailAndPassword(
          email: email, password: pass);
    } catch (e) {
      print(e);
    }
  }

  void loginEmailPass(email, pass) async {
    try {
      await firebaseInstance.signInWithEmailAndPassword(
          email: email, password: pass);
    } catch (e) {
      print(e);
    }
  }

  void resetPassword(email) async {
    try {
      await firebaseInstance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future<FirebaseUser> getUser() async {
    return await firebaseInstance.currentUser();
  }
}
