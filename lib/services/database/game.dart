import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iprecious/models/database_models/multiplayer.dart';

class Multiplayer {
  final uniqueId;
  final haha;
  final readyOne;
  final readyTwo;
  Multiplayer({this.uniqueId, this.haha, this.readyOne, this.readyTwo});
  var _ref = Firestore.instance;

  //send info to firebase
  Future sendInfo(final turn, final player2NumStatus, final winner,
      final theNumber, final coins) async {
    return await _ref.collection("Multiplayer").document(uniqueId).setData({
      "turn": turn,
      "player2NumStatus": player2NumStatus,
      "winner": winner,
      "theNumber": theNumber,
      "coins": coins,
    });
  }

  //send ready info to firebase
  Future sendReadyInfo(final readyState) async {
    return await _ref
        .collection("Multiplayer")
        .document(uniqueId)
        .collection("Ready")
        .document(haha)
        .setData({
      "isOpponentReady": readyState,
    });
  }

  //send winner info
  Future sendWinnerInfo(final _uid, final _amount, final _date) async {
    await _ref.collection("Users").document(_uid).get().then((onValue) {
      _ref.collection("Game").document("Coins").collection("Won").add({
        "gameMod": "Play with friends",
        "userName": onValue.data["userName"],
        "userPhone": onValue.data["userPhone"],
        "amount": _amount,
        "date": _date
      });
    });
    await _ref
        .collection("Users")
        .document(_uid)
        .collection("WonLost")
        .document("WonLost")
        .get()
        .then((onValue) {
      _ref
          .collection("Users")
          .document(_uid)
          .collection("WonLost")
          .document("WonLost")
          .setData({
        "gameWon": onValue.data["gameWon"] + 1,
        "gameLost": onValue.data["gameLost"],
      });
    });
  }

  //send loser info
  Future sendLoserInfo(final _uid, final _amount, final _date) async {
    await _ref.collection("Users").document(_uid).get().then((onValue) {
      _ref.collection("Game").document("Coins").collection("Lost").add({
        "gameMod": "Play with friends",
        "userName": onValue.data["userName"],
        "userPhone": onValue.data["userPhone"],
        "amount": _amount,
        "date": _date
      });
    });
    await _ref
        .collection("Users")
        .document(_uid)
        .collection("WonLost")
        .document("WonLost")
        .get()
        .then((onValue) {
      _ref
          .collection("Users")
          .document(_uid)
          .collection("WonLost")
          .document("WonLost")
          .setData({
        "gameWon": onValue.data["gameWon"],
        "gameLost": onValue.data["gameLost"] + 1,
      });
    });
  }

  //get multiplayer model from firebase
  MultiplayerModel _multiplayerFromFirebase(DocumentSnapshot snapshot) {
    return MultiplayerModel(
        snapshot.data["turn"],
        snapshot.data["player2NumStatus"],
        snapshot.data["winner"],
        snapshot.data["theNumber"],
        snapshot.data["coins"]);
  }

  //get ready from firebase
  ReadyModel _readyModel(DocumentSnapshot snapshot) {
    return ReadyModel(
      snapshot.data["isOpponentReady"],
    );
  }

  ReadyModel1 _readyModel1(DocumentSnapshot snapshot) {
    return ReadyModel1(
      snapshot.data["isOpponentReady"],
    );
  }

  ReadyModel2 _readyModel2(DocumentSnapshot snapshot) {
    return ReadyModel2(
      snapshot.data["isOpponentReady"],
    );
  }

  //streams of multiplayer
  Stream<MultiplayerModel> get multiplayer {
    return _ref
        .collection("Multiplayer")
        .document(uniqueId)
        .snapshots()
        .map(_multiplayerFromFirebase);
  }

  //stream of readyState
  Stream<ReadyModel> get ready {
    return _ref
        .collection("Multiplayer")
        .document(uniqueId)
        .collection("Ready")
        .document(haha)
        .snapshots()
        .map(_readyModel);
  }

  Stream<ReadyModel1> get ready1 {
    return _ref
        .collection("Multiplayer")
        .document(uniqueId)
        .collection("Ready")
        .document(readyOne)
        .snapshots()
        .map(_readyModel1);
  }

  Stream<ReadyModel2> get ready2 {
    return _ref
        .collection("Multiplayer")
        .document(uniqueId)
        .collection("Ready")
        .document(readyTwo)
        .snapshots()
        .map(_readyModel2);
  }
}
