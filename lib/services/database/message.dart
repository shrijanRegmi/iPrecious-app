import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iprecious/models/database_models/msg.dart';
import 'package:iprecious/models/database_models/user.dart';

class MessageProvider {
  final uid;
  final uniqueId;
  MessageProvider({this.uid, this.uniqueId});

  final _ref = Firestore.instance;

  //list of users from firebase
  List<User> _usersListFromFirebase(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return User(
        uid: doc.data["uid"] ?? "",
        userName: doc.data["userName"] ?? "",
        userEmail: doc.data["userEmail"] ?? "",
        profileImgNum: doc.data["profileImgNum"],
        userNcell: doc.data["userNcell"] ?? "",
        userNtc: doc.data["userNtc"] ?? "",
        ntcScode: doc.data["scode"] ?? "",
      );
    }).toList();
  }

  //send messages
  Future sendMsg({
    final uniqueId,
    final msg,
    final senderId,
    final receiverId,
    final date,
    final seenState,
    final challenge,
  }) async {
    return await _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .add({
      "msg": msg,
      "sender": senderId,
      "receiver": receiverId,
      "date": date,
      "seenState": seenState,
    });
  }

  //delete msg
  Future deleteMsg(final documentId) async {
    return await _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .document(documentId)
        .delete();
  }

  //update seen state of chat
  Future updateSeenStateChat(final uniqueId, final seenState) async {
    return await _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .getDocuments()
        .then((onValue) {
      onValue.documents.forEach((element) async {
        await _ref
            .collection("Messages")
            .document("Messages")
            .collection(uniqueId)
            .document(element.documentID)
            .updateData({
          "seenState": seenState,
        });
      });
    });
  }

  //send squad
  Future sendSquad(
      {final uniqueId,
      final msg,
      final senderId,
      final receiverId,
      final date,
      final seenState}) async {
    return await _ref.collection("Messages").document(uniqueId).setData({
      "msg": msg,
      "sender": senderId,
      "receiver": receiverId,
      "date": date,
      "seenState": seenState,
    });
  }

  //update seenstate of message
  Future updateSeenStateMessage(final uniqueId, final seenState) async {
    return await _ref.collection("Messages").document(uniqueId).updateData({
      "seenState": seenState,
    });
  }

  //send challenge
  Future sendChallenge(final challenge) async {
    return await _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .document("Challenge")
        .setData({
          "challenge" : challenge,
        });
  }

  /////////////////////////////////////////////////////////////////////////////get from firebase

  //msg from firebase
  List<Message> _msgFromFirebase(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Message(
        msg: doc.data["msg"] ?? "",
        sender: doc.data["sender"] ?? "",
        receiver: doc.data["receiver"] ?? "",
        date: doc.data["date"] ?? "",
        seenState: doc.data["seenState"] ?? false,
      );
    }).toList();
  }

  //squad from firebase
  List<Message> _squadFromFirebase(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Message(
        msg: doc.data["msg"] ?? "",
        sender: doc.data["sender"] ?? "",
        receiver: doc.data["receiver"] ?? "",
        date: doc.data["date"] ?? "",
        seenState: doc.data["seenState"] ?? false,
      );
    }).toList();
  }

  //challenge from firebase
  Challenge _challengeFromFirebase(DocumentSnapshot snapshot) {
    return Challenge(snapshot.data["challenge"]);
  }

  ///////////////////////////////////////////////////////////////////////////////streams

  //stream of user list
  Stream<List<User>> get usersList {
    return _ref.collection("Users").snapshots().map(_usersListFromFirebase);
  }

  //stream of message list
  Stream<List<Message>> get messageList {
    return _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .orderBy("date", descending: true)
        .snapshots()
        .map(_msgFromFirebase);
  }

  //stream of squad list
  Stream<List<Message>> get squadList {
    return _ref.collection("Messages").orderBy("date", descending: true).snapshots().map(_squadFromFirebase);
  }

  //stream of challenge
  Stream<Challenge> get challenge {
    return _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .document("Challenge")
        .snapshots()
        .map(_challengeFromFirebase);
  }
}
