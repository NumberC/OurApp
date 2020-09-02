import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_app/Core/FirebasDB.dart';

class Authentication {
  FirebaseAuth firebaseInstance = FirebaseAuth.instance;
  FirebaseDB firebaseDB = new FirebaseDB();

  Future<bool> isUserLoggedIn() async {
    return await firebaseInstance.currentUser() != null;
  }

  Future<AuthResult> registerEmailPass(email, pass) async {
    try {
      AuthResult authResult = await firebaseInstance
          .createUserWithEmailAndPassword(email: email, password: pass);
      await firebaseDB.addNewUserInfo(await getUser());
      return authResult;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteAccount(FirebaseUser user) async {
    await firebaseDB.deleteUserInfo(user);
    await user.delete();
  }

  Future<AuthResult> loginEmailPass(email, pass) async {
    try {
      return await firebaseInstance.signInWithEmailAndPassword(
          email: email, password: pass);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> resetPassword(email) async {
    try {
      await firebaseInstance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future<void> logOut() async {
    await firebaseInstance.signOut();
  }

  Future<FirebaseUser> getUser() async {
    return await firebaseInstance.currentUser();
  }
}
