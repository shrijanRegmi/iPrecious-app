import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iprecious/models/database_models/msg.dart';
import 'package:iprecious/models/database_models/multiplayer.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/models/list_models/game_modes.dart';
import 'package:iprecious/screens/widgets/drawer.dart';
import 'package:iprecious/screens/widgets/normalButton.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:iprecious/services/database/game.dart';
import 'package:iprecious/services/database/message.dart';
import 'package:provider/provider.dart';

import 'game_screen_multiplayer.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
  final _data;
  ChatsScreen(this._data) : super();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context) ?? User(uid: "");
    return MultiProvider(providers: [
      StreamProvider<List<Message>>.value(
        value: MessageProvider(
                uid: _user.uid,
                uniqueId: _user.uid.hashCode > widget._data.uid.hashCode
                    ? "${_user.uid}${widget._data.uid}"
                    : "${widget._data.uid}${_user.uid}")
            .messageList,
      ),
      StreamProvider<User>.value(
        value: DatabaseProvider(
          uid: _user.uid,
        ).userDetail,
      ),
      StreamProvider<Challenge>.value(
        value: MessageProvider(
                uniqueId: _user.uid.hashCode > widget._data.uid.hashCode
                    ? "${_user.uid}${widget._data.uid}"
                    : "${widget._data.uid}${_user.uid}")
            .challenge,
      ),
      StreamProvider<MultiplayerModel>.value(
          value: Multiplayer(
                  uniqueId: _user.uid.hashCode > widget._data.uid.hashCode
                      ? "${_user.uid}${widget._data.uid}"
                      : "${widget._data.uid}${_user.uid}")
              .multiplayer),
      StreamProvider<Points>.value(
          value: DatabaseProvider(uid: _user.uid).points)
    ], child: Chats(_user.uid, widget._data));
  }
}

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
  final _me;
  final _data;
  Chats(this._me, this._data) : super();
}

class _ChatsState extends State<Chats> {
  AdmobReward _admobReward;
  AdmobInterstitial _interstitialAd;

  @override
  void initState() {
    super.initState();
    _interstitialAd = AdmobInterstitial(
        adUnitId: "ca-app-pub-4056821571384483/9120203477",
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.closed) _interstitialAd.load();
        });
    _admobReward = AdmobReward(
        adUnitId: "ca-app-pub-4056821571384483/8995547566",
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          var _ref = Firestore.instance;
          switch (event) {
            case AdmobAdEvent.closed:
              _admobReward.load();
              setState(() {
                _adFailed = false;
              });
              break;
            case AdmobAdEvent.rewarded:
              _admobReward.load();
              _ref
                  .collection("Users")
                  .document(widget._me)
                  .get()
                  .then((onValue) {
                DatabaseProvider(uid: widget._me)
                    .sendPlayRequest(onValue.data["playLife"] + 2);
              });
              setState(() {
                _adFailed = false;
              });
              break;
            default:
          }
        });
    _interstitialAd.load();
    _admobReward.load();
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    _admobReward.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _msgController = TextEditingController();
  bool _typeSectionVisibility = false;
  bool _topSectionVisibility = true;
  bool _adFailed = false;

  int _currentSelectedCoins = 5;

  var me = "";
  var _myCoins = 0;
  var _myLife = 0;

  Future<void> _showNoLifeDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 30.0),
                    width: MediaQuery.of(context).size.width - 100,
                    height: 400.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 50.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _adFailed
                                      ? "Sorry! no videos are available currently"
                                      : "You don't have enough play life!!!",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _adFailed
                                      ? "Try again later"
                                      : "Watch a video to earn 2 play lives",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        _adFailed
                            ? StickyButton("OK", "", () async {
                                Navigator.pop(context);
                                if (await _admobReward.isLoaded) {
                                  setState(() {
                                    _adFailed = false;
                                  });
                                }
                              })
                            : StickyButton("Watch Now", "images/movie.svg",
                                () async {
                                if (await _admobReward.isLoaded) {
                                  Navigator.pop(context);
                                  _admobReward.show();
                                  setState(() {
                                    _adFailed = false;
                                  });
                                } else {
                                  setState(() {
                                    _adFailed = true;
                                  });
                                }
                              }),
                        SizedBox(
                          height: 10.0,
                        ),
                        _adFailed
                            ? Container()
                            : StickyButton("Cancel", "", () {
                                Navigator.pop(context);
                              }),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> _acceptDialog(var _multiplayer) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 30.0),
                    width: MediaQuery.of(context).size.width - 100,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        StreamBuilder(
                          stream: Multiplayer(
                                  uniqueId:
                                      me.hashCode > widget._data.uid.hashCode
                                          ? "$me${widget._data.uid}"
                                          : "${widget._data.uid}$me")
                              .multiplayer,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    child: Row(
                                      children: <Widget>[
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Waiting for other player...",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "(Please don't leave this screen)",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  StickyButton("Leave anyway", "", () {
                                    Navigator.pop(context);
                                  }),
                                ],
                              );
                            } else {
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    child: Text(
                                      "Connected",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  StickyButton("Play", "", () {
                                    if (_myCoins >= _multiplayer.coins) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GameScreenMultiplayer(
                                                    me,
                                                    widget._data.uid,
                                                    _currentSelectedCoins,
                                                  )));
                                    } else {
                                      Navigator.pop(context);
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text("Not enough coins"),
                                      ));
                                    }
                                  }),
                                ],
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context) ?? User(uid: "");
    final _points = Provider.of<Points>(context);
    setState(() {
      me = _user.uid;
      _myCoins = _points != null ? _points.coins : 0;
      _myLife = _user != null ? _user.playLife : 0;
    });
    final _messageList = Provider.of<List<Message>>(context) ?? [];
    return StreamProvider<User>.value(
      value: DatabaseProvider(uid: widget._data.uid).userDetail,
      child: StreamProvider<Points>.value(
          value: DatabaseProvider(uid: widget._data.uid).points,
          child: StreamProvider<Achievements>.value(
            value: DatabaseProvider(uid: widget._data.uid).achievement,
            child: Scaffold(
              key: _scaffoldKey,
              endDrawer: MyDrawer(
                from: "Message",
              ),
              body: Container(
                child: Column(
                  children: <Widget>[
                    _topSection(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AdmobBanner(
                          adUnitId: "ca-app-pub-4056821571384483/8381836879",
                          adSize: AdmobBannerSize.BANNER,
                        ),
                      ],
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _topSectionVisibility = !_topSectionVisibility;
                            _typeSectionVisibility = false;
                          });
                        },
                        child: ListView.builder(
                          reverse: true,
                          itemCount: _messageList.length,
                          itemBuilder: (context, index) {
                            if (_messageList[index].sender == _user.uid) {
                              return _getChatsListItemRight(
                                  context, _messageList[index]);
                            } else {
                              return _getChatsListItemLeft(
                                  context, _messageList[index]);
                            }
                          },
                        ),
                      ),
                    ),
                    _typeSection(context),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _topSection() {
    return Container(
      padding: EdgeInsets.only(bottom: _topSectionVisibility ? 30.0 : 10.0),
      decoration: BoxDecoration(
          color: Color(0xff5317e1),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
      child: Column(
        children: <Widget>[
          _appbarSection(),
          _topSectionVisibility
              ? _userDetail()
              : SizedBox(
                  height: 0.0,
                ),
        ],
      ),
    );
  }

  Widget _appbarSection() {
    final _user = Provider.of<User>(context);
    final _multiplayer = Provider.of<MultiplayerModel>(context);
    final _points = Provider.of<Points>(context);

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0, right: 30.0, left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30.0,
              ),
            ),
            _topSectionVisibility
                ? MyButton(
                    _user != null
                        ? "Play game (${_user.playLife})"
                        : "Play game (0)", () async {
                    if (_user.playLife > 0) {
                      if (await _interstitialAd.isLoaded) {
                        _interstitialAd.show();
                      }
                    }
                    _playDialog(_multiplayer, _user, _points);
                    await MessageProvider(
                      uniqueId: _user.uid.hashCode > widget._data.uid.hashCode
                          ? "${_user.uid}${widget._data.uid}"
                          : "${widget._data.uid}${_user.uid}",
                    ).sendChallenge(true);
                  })
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: 35.0,
                      height: 35.0,
                      child: Image.asset(
                        "images/avatars/${widget._data.profileImgNum}.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            GestureDetector(
              onTap: () async {
                _interstitialAd.load();
                if (await _interstitialAd.isLoaded) {
                  _interstitialAd.show();
                }
                _scaffoldKey.currentState.openEndDrawer();
              },
              child: Container(
                height: 55.0,
                width: 43.0,
                alignment: Alignment.topCenter,
                child: Text(
                  "...",
                  style: TextStyle(
                    fontSize: 35.0,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _userDetail() {
    return Container(
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              child: Image.asset(
                "images/avatars/${widget._data.profileImgNum}.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            widget._data.userName,
            style: TextStyle(
                fontSize: 16.0,
                fontFamily: "Mont",
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _getChatsListItemRight(BuildContext context, var _data) {
    final _user = Provider.of<User>(context) ?? User(uid: "");
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _data.sender == _user.uid && _data.seenState
              ? Text(
                  "Seen",
                  style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                )
              : Container(),
          Container(
            constraints: BoxConstraints(
              maxWidth: 200,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(3.0, 3.0),
                      blurRadius: 15.0)
                ],
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                )),
            child: _data.msg.contains("Sent a play request")
                ? Text(
                    "You sent a play request of ${_data.msg.toString().substring(23)} coins!",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  )
                : _data.msg == "I am not playing now!"
                    ? Text(
                        _data.msg,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      )
                    : Text(
                        _data.msg,
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _getChatsListItemLeft(BuildContext context, var _data) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxWidth: 200,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(3.0, 3.0),
                      blurRadius: 15.0)
                ],
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                )),
            child: _data.msg.contains("Sent a play request")
                ? Column(
                    children: <Widget>[
                      Text(
                        "I challenge you to play a game of ${_data.msg.toString().substring(23)} coins!",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (_myCoins >=
                                        int.parse(
                                            "${_data.msg.toString().substring(23)}") &&
                                    _myLife > 0) {
                                  var _rand = Random();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GameScreenMultiplayer(
                                                me,
                                                widget._data.uid,
                                                int.parse(
                                                    "${_data.msg.toString().substring(23)}"),
                                              )));
                                  await Multiplayer(
                                          uniqueId: me.hashCode >
                                                  widget._data.uid.hashCode
                                              ? "$me${widget._data.uid}"
                                              : "${widget._data.uid}$me")
                                      .sendInfo(
                                          "",
                                          "",
                                          "",
                                          _rand.nextInt(500),
                                          int.parse(
                                              "${_data.msg.toString().substring(23)}"));
                                  var _ref = Firestore.instance;
                                  await _ref
                                      .collection("Messages")
                                      .document("Messages")
                                      .collection(me.hashCode >
                                              widget._data.uid.hashCode
                                          ? "$me${widget._data.uid}"
                                          : "${widget._data.uid}$me")
                                      .getDocuments()
                                      .then((onValue) {
                                    onValue.documents.forEach((f) async {
                                      if (_data.msg == f.data["msg"] &&
                                          _data.date == f.data["date"]) {
                                        await MessageProvider(
                                                uniqueId: me.hashCode >
                                                        widget
                                                            ._data.uid.hashCode
                                                    ? "$me${widget._data.uid}"
                                                    : "${widget._data.uid}$me")
                                            .deleteMsg(f.documentID);
                                      }
                                    });
                                  });
                                  await DatabaseProvider(uid: me)
                                      .sendPlayRequest(_myLife - 1);
                                } else if (_myLife <= 0) {
                                  return _showNoLifeDialog();
                                } else {
                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                          "You don't have ${_data.msg.toString().substring(23)} coins")));
                                  return _declineRequest(
                                      me.hashCode > widget._data.uid.hashCode
                                          ? "$me${widget._data.uid}"
                                          : "${widget._data.uid}$me",
                                      _data.msg,
                                      _data.date);
                                }
                              },
                              child: Container(
                                child: Center(
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.lightBlueAccent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                _declineRequest(
                                    me.hashCode > widget._data.uid.hashCode
                                        ? "$me${widget._data.uid}"
                                        : "${widget._data.uid}$me",
                                    _data.msg,
                                    _data.date);

                                await MessageProvider().sendSquad(
                                  uniqueId:
                                      me.hashCode > widget._data.uid.hashCode
                                          ? "$me${widget._data.uid}"
                                          : "${widget._data.uid}$me",
                                  msg: "I am not playing now!",
                                  senderId: me,
                                  receiverId: widget._data.uid,
                                  date: DateTime.now().toString(),
                                  seenState: false,
                                );
                              },
                              child: Container(
                                child: Center(
                                  child: Text(
                                    "Decline",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : _data.msg == "I am not playing now!"
                    ? Text(
                        _data.msg,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      )
                    : Text(
                        _data.msg,
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _typeSection(BuildContext context) {
    final _user = Provider.of<User>(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _typeSectionVisibility
                      ? Colors.black.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextFormField(
                  controller: _msgController,
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  onTap: () {
                    setState(() {
                      _topSectionVisibility = false;
                      _typeSectionVisibility = true;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding: _typeSectionVisibility
                          ? EdgeInsets.all(13.0)
                          : EdgeInsets.only(
                              left:
                                  MediaQuery.of(context).size.width / 2 - 60.0,
                              top: 10.0,
                              bottom: 10.0),
                      border: InputBorder.none,
                      hintText: _typeSectionVisibility
                          ? "Type something..."
                          : "Tap here to type",
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontFamily: "Mont")),
                ),
              ),
            ),
          ),
          _typeSectionVisibility
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.image),
                  color: Colors.black,
                )
              : SizedBox(
                  width: 0.0,
                ),
          _typeSectionVisibility
              ? IconButton(
                  onPressed: () async {
                    var _msgTemp = "";
                    if (_msgController.text != "") {
                      setState(() {
                        _msgTemp = _msgController.text;
                      });
                      _msgController.clear();
                      await MessageProvider().sendMsg(
                        uniqueId: _user.uid.hashCode > widget._data.uid.hashCode
                            ? "${_user.uid}${widget._data.uid}"
                            : "${widget._data.uid}${_user.uid}",
                        msg: _msgTemp.trim(),
                        senderId: _user.uid,
                        receiverId: widget._data.uid,
                        date: DateTime.now().toString(),
                        seenState: false,
                      );
                      await MessageProvider().sendSquad(
                        uniqueId: _user.uid.hashCode > widget._data.uid.hashCode
                            ? "${_user.uid}${widget._data.uid}"
                            : "${widget._data.uid}${_user.uid}",
                        msg: _msgTemp.trim(),
                        senderId: _user.uid,
                        receiverId: widget._data.uid,
                        date: DateTime.now().toString(),
                        seenState: false,
                      );
                    }
                  },
                  icon: Icon(Icons.send),
                  color: Colors.black,
                )
              : SizedBox(
                  width: 0.0,
                ),
        ],
      ),
    );
  }

  Future _declineRequest(var uniqueId, var msg, var date) async {
    var _ref = Firestore.instance;
    return await _ref
        .collection("Messages")
        .document("Messages")
        .collection(uniqueId)
        .getDocuments()
        .then((onValue) {
      onValue.documents.forEach((f) async {
        if (msg == f.data["msg"] && date == f.data["date"]) {
          await MessageProvider(uniqueId: uniqueId).deleteMsg(f.documentID);
          await MessageProvider().sendMsg(
            uniqueId: uniqueId,
            msg: "I am not playing now!",
            senderId: me,
            receiverId: widget._data.uid,
            date: DateTime.now().toString(),
            seenState: false,
          );
        }
      });
    });
  }

  Future<void> _playDialog(final _multiplayer, final _user, final _points) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.of(context).size.width - 100,
              height: 400.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100.0,
                                  child: SvgPicture.asset(
                                    "images/coins.svg",
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Play with friends",
                                style: TextStyle(
                                    fontSize: 20.0, color: Color(0xff722FA4)),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  "Play online (1v1) and get to win coins upto 30000!",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey.withOpacity(0.7)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Select the bot amount:",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.green),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    isDense: true,
                                    items: coinsList.map((int dropdownItem) {
                                      return DropdownMenuItem(
                                        value: dropdownItem,
                                        child: Text("$dropdownItem"),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _currentSelectedCoins = value;
                                      });
                                    },
                                    value: _currentSelectedCoins,
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "<Winning coins $_currentSelectedCoins>",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: MyButton("Play now", () async {
                            Navigator.pop(context);
                            if (_points.coins >= _currentSelectedCoins &&
                                _user.playLife > 0) {
                              if (await _admobReward.isLoaded) {
                                setState(() {
                                  _adFailed = false;
                                });
                              }
                              _acceptDialog(_multiplayer);
                              await DatabaseProvider(uid: _user.uid)
                                  .sendPlayRequest(_user.playLife - 1);
                              await MessageProvider().sendMsg(
                                uniqueId: _user.uid.hashCode >
                                        widget._data.uid.hashCode
                                    ? "${_user.uid}${widget._data.uid}"
                                    : "${widget._data.uid}${_user.uid}",
                                msg:
                                    "Sent a play request of $_currentSelectedCoins",
                                senderId: _user.uid,
                                receiverId: widget._data.uid,
                                date: DateTime.now().toString(),
                                seenState: false,
                              );
                              await MessageProvider().sendSquad(
                                uniqueId: _user.uid.hashCode >
                                        widget._data.uid.hashCode
                                    ? "${_user.uid}${widget._data.uid}"
                                    : "${widget._data.uid}${_user.uid}",
                                msg: "Let's Play",
                                senderId: _user.uid,
                                receiverId: widget._data.uid,
                                date: DateTime.now().toString(),
                                seenState: false,
                              );
                            } else if (_user.playLife <= 0) {
                              return _showNoLifeDialog();
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "You don't have $_currentSelectedCoins coins"),
                              ));
                            }
                          }),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
