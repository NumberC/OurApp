import 'package:catcher/catcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Core/UserDB.dart';

class Authentication {
  FirebaseAuth instance = FirebaseAuth.instance;

  bool isUserLoggedIn() => instance.currentUser != null;

  Future<UserCredential> registerEmailPass(String email, String pass) async {
    try {
      UserCredential authResult = await instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      //TODO: should authentication depend on userDB?
      await UserDB(authResult.user.uid).createUserInfo(authResult.user);
      return authResult;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteAccount(User user) async {
    await UserDB(user.uid).deleteUserInfo();
    try {
      await user.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential> loginEmailPass(String email, String pass) async {
    try {
      return await instance.signInWithEmailAndPassword(
          email: email, password: pass);
    } catch (e) {
      print(e);
      Catcher.sendTestException();
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future<void> logOut() async => await instance.signOut();
  User getUser() => instance.currentUser;
}
