import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iprecious/models/database_models/active_user.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';

class DatabaseProvider {
  final uid;
  DatabaseProvider({this.uid});

  final _ref = Firestore.instance;

  /////////////////////////////////////////////////////send to firebase

  //update user details
  Future updateUserData(final _userName, final _userEmail, final _profileImgNum,
      final _userNcell, final _userNtc, final _scode, _playLife) async {
    return await _ref.collection("Users").document(uid).setData({
      "uid": uid,
      "userName": _userName,
      "userEmail": _userEmail,
      "profileImgNum": _profileImgNum,
      "userNcell": _userNcell,
      "userNtc": _userNtc,
      "scode": _scode,
      "playLife": _playLife,
    });
  }

  //upadate user points
  Future updateUserPoints({final cash, final gems, final coins}) async {
    return await _ref
        .collection("Users")
        .document(uid)
        .collection("Points")
        .document("Points")
        .setData({
      "cash": cash,
      "coins": coins,
      "gems": gems,
    });
  }

  //update user achievements
  Future updateUserAchievements({final gameWon, final gameLost}) async {
    return await _ref
        .collection("Users")
        .document(uid)
        .collection("WonLost")
        .document("WonLost")
        .setData({
      "gameWon": gameWon,
      "gameLost": gameLost,
    });
  }

  //send winner info to firebase
  Future sendWinnerInfo(final _gameMod, final _userName, final _amount,
      final _userPhone, final _date) async {
    return await _ref
        .collection("Game")
        .document(_gameMod == "Online with cash" ? "Cash" : "Coins")
        .collection("Won")
        .add({
      "gameMod": _gameMod,
      "userName": _userName,
      "userPhone": _userPhone,
      "amount": _amount,
      "date": _date
    });
  }

  //send loser info to firebase
  Future sendLoserInfo(final _gameMod, final _userName, final _amount,
      final _userPhone, final _date) async {
    return await _ref
        .collection("Game")
        .document(_gameMod == "Online with cash" ? "Cash" : "Coins")
        .collection("Lost")
        .add({
      "gameMod": _gameMod,
      "userName": _userName,
      "userPhone": _userPhone,
      "amount": _amount,
      "date": _date,
    });
  }

  //send buyers info to firebase
  Future buyCoins(final _coins, final _cash, final _userName, final _userPhone,
      final _date) async {
    return await _ref.collection("Buy").add({
      "coins": _coins,
      "with": _cash,
      "uid": uid,
      "userName": _userName,
      "userPhone": _userPhone,
      "date": _date
    });
  }

  //send exchange info to fireabse
  Future exchangeCoinsWithCash(final _coins, final _cash, final _userName,
      final _userPhone, final _date) async {
    return await _ref.collection("Exchange").add({
      "coins": _coins,
      "toGet": _cash,
      "userName": _userName,
      "userPhone": _userPhone,
      "date": _date,
    });
  }

  //send active user to firebase
  Future sendActiveUsers() async {
    await _ref.collection("ActiveUsers").document(uid).setData({
      "activeUser": uid,
    });
  }

  //remove active user
  Future deleteActiveUser() async {
    await _ref.collection("ActiveUsers").document(uid).delete();
  }

  //send play request
  Future sendPlayRequest(final _playLife) async {
    return _ref.collection("Users").document(uid).updateData({
      "playLife": _playLife,
    });
  }

  /////////////////////////////////////////////////////////////get from firebase

  //user details from firebase
  User _userFromFirebase(DocumentSnapshot snapshot) {
    return User(
      uid: snapshot.data["uid"],
      userName: snapshot.data["userName"],
      userEmail: snapshot.data["userEmail"],
      profileImgNum: snapshot.data["profileImgNum"],
      userNcell: snapshot.data["userNcell"],
      userNtc: snapshot.data["userNtc"],
      ntcScode: snapshot.data["scode"],
      playLife: snapshot.data["playLife"] ?? 5,
    );
  }

  //points from firebase
  Points _pointsFromFirebase(DocumentSnapshot snapshot) {
    return Points(
      cash: snapshot.data["cash"] ?? 0,
      coins: snapshot.data["coins"] ?? 0,
      gems: snapshot.data["gems"] ?? 0,
    );
  }

  //achievements from firebase
  Achievements _achievementFromFirebase(DocumentSnapshot snapshot) {
    return Achievements(
      gameWon: snapshot.data["gameWon"] ?? 0,
      gameLost: snapshot.data["gameLost"] ?? 0,
    );
  }

  //list of users from firebase
  List<User> _usersListFromFirebase(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return User(
        uid: doc.data["uid"] ?? "",
        userName: doc.data["userName"] ?? "",
        userEmail: doc.data["userEmail"] ?? "",
        userNcell: doc.data["userNcell"] ?? "",
        userNtc: doc.data["userNtc"] ?? "",
        ntcScode: doc.data["scode"] ?? "",
        playLife: doc.data["playLife"] ?? 5,
      );
    }).toList();
  }

  //list of active users from firebase
  List<ActiveUser> _activeUserFromFirebase(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return ActiveUser(doc.data["activeUser"]);
    }).toList();
  }

  //////////////////////////////////////////////streams

  //stream of user
  Stream<User> get userDetail {
    return _ref
        .collection("Users")
        .document(uid)
        .snapshots()
        .map(_userFromFirebase);
  }

  //stream of user list
  Stream<List<User>> get usersList {
    return _ref.collection("Users").snapshots().map(_usersListFromFirebase);
  }

  //stream of points
  Stream<Points> get points {
    return _ref
        .collection("Users")
        .document(uid)
        .collection("Points")
        .document("Points")
        .snapshots()
        .map(_pointsFromFirebase);
  }

  //stream of achievement
  Stream<Achievements> get achievement {
    return _ref
        .collection("Users")
        .document(uid)
        .collection("WonLost")
        .document("WonLost")
        .snapshots()
        .map(_achievementFromFirebase);
  }

  //stream of active user
  Stream<List<ActiveUser>> get activeUser {
    return _ref
        .collection("ActiveUsers")
        .snapshots()
        .map(_activeUserFromFirebase);
  }
}
