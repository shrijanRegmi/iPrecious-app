import 'package:firebase_auth/firebase_auth.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/services/database/database.dart';

class AuthProvider {
  final _auth = FirebaseAuth.instance;

  //create user account
  Future createUserAccount(final _userName, final _email, final _profileImgNum,
      final _userNcell, final _userNtc, final _scode, final _pass) async {
    try {
      final _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _pass);

      await DatabaseProvider(uid: _result.user.uid).updateUserData(
          _userName, _email, _profileImgNum, _userNcell, _userNtc, _scode, 5);

      await DatabaseProvider(uid: _result.user.uid).updateUserPoints(
        coins: 0,
        cash: 0,
        gems: 0,
      );

      await DatabaseProvider(uid: _result.user.uid).updateUserAchievements(
        gameWon: 0,
        gameLost: 0,
      );

      return _userFromFirebase(_result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //login user
  Future loginUser(final _email, final _pass) async {
    try {
      final _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _pass);
      return _userFromFirebase(_result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //signout user
  Future signOut() async {
    return await _auth.signOut();
  }

  //user from firebase
  User _userFromFirebase(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  //stream of user
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebase);
  }
}
