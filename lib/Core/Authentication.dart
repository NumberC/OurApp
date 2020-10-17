import 'package:catcher/catcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_app/Core/FirebaseDB.dart';

class Authentication {
  FirebaseAuth instance = FirebaseAuth.instance;

  Future<bool> isUserLoggedIn() async => await instance.currentUser() != null;

  Future<AuthResult> registerEmailPass(String email, String pass) async {
    try {
      AuthResult authResult = await instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await FirebaseDB.addNewUserInfo(await getUser());
      return authResult;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteAccount(FirebaseUser user) async {
    await FirebaseDB.deleteUserInfo(user);
    try {
      await user.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<AuthResult> loginEmailPass(String email, String pass) async {
    try {
      return await instance.signInWithEmailAndPassword(
          email: email, password: pass);
    } catch (e) {
      print(e);
      //Catcher.sendTestException();
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
  Future<FirebaseUser> getUser() async => await instance.currentUser();
}
