import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:iprecious/models/database_models/multiplayer.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:iprecious/services/database/game.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GameScreenMultiplayer extends StatefulWidget {
  @override
  _GameScreenMultiplayerState createState() => _GameScreenMultiplayerState();
  final _player1;
  final _player2;
  final _coins;
  GameScreenMultiplayer(this._player1, this._player2, this._coins) : super();
}

class _GameScreenMultiplayerState extends State<GameScreenMultiplayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: DatabaseProvider(uid: _user.uid).userDetail,
        ),
        StreamProvider<Points>.value(
          value: DatabaseProvider(uid: _user.uid).points,
        ),
        StreamProvider<Achievements>.value(
          value: DatabaseProvider(uid: _user.uid).achievement,
        ),
        StreamProvider<MultiplayerModel>.value(
          value: Multiplayer(
                  uniqueId: widget._player1.hashCode > widget._player2.hashCode
                      ? "${widget._player1}${widget._player2}"
                      : "${widget._player2}${widget._player1}")
              .multiplayer,
        ),
        StreamProvider<ReadyModel>.value(
          value: Multiplayer(
                  uniqueId: widget._player1.hashCode > widget._player2.hashCode
                      ? "${widget._player1}${widget._player2}"
                      : "${widget._player2}${widget._player1}",
                  haha: widget._player1)
              .ready,
        ),
        StreamProvider<ReadyModel1>.value(
          value: Multiplayer(
            uniqueId: widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}",
            readyOne: widget._player1,
          ).ready1,
        ),
        StreamProvider<ReadyModel2>.value(
          value: Multiplayer(
                  uniqueId: widget._player1.hashCode > widget._player2.hashCode
                      ? "${widget._player1}${widget._player2}"
                      : "${widget._player2}${widget._player1}",
                  readyTwo: widget._player2)
              .ready2,
        ),
      ],
      child: SafeArea(
        child: Scaffold(
            body: Hahaha(
          widget._player1,
          widget._player2,
          widget._player1.hashCode > widget._player2.hashCode
              ? widget._player1
              : widget._player2,
          widget._coins,
        )),
      ),
    );
  }
}

class Hahaha extends StatelessWidget {
  final _player1;
  final _player2;
  final _turn;
  final _coins;
  Hahaha(this._player1, this._player2, this._turn, this._coins);
  @override
  Widget build(BuildContext context) {
    final _multiplayer = Provider.of<MultiplayerModel>(context);
    return GameViewMultiplayer(
      _player1,
      _player2,
      _turn,
      _multiplayer.theNumber,
      _coins,
    );
  }
}

class GameViewMultiplayer extends StatefulWidget {
  @override
  _GameViewMultiplayerState createState() => _GameViewMultiplayerState();
  final _turn;
  final _player1;
  final _player2;
  final _theNumber;
  final _coins;
  GameViewMultiplayer(
      this._player1, this._player2, this._turn, this._theNumber, this._coins)
      : super();
}

class _GameViewMultiplayerState extends State<GameViewMultiplayer> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _turn = widget._turn;
    });
    Multiplayer(
            uniqueId: widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}",
            haha: widget._player2)
        .sendReadyInfo(false);
    Multiplayer(
            uniqueId: widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}",
            haha: widget._player1)
        .sendReadyInfo(false);
    Multiplayer(
            uniqueId: widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}")
        .sendInfo(_turn, "", "", widget._theNumber, widget._coins);
  }

  @override
  void dispose() {
    var _ref = Firestore.instance;
    _ref
        .collection("Multiplayer")
        .document(widget._player1.hashCode > widget._player2.hashCode
            ? "${widget._player1}${widget._player2}"
            : "${widget._player2}${widget._player1}")
        .get()
        .then((onValue) {
      if (onValue != null) {
        _ref
            .collection("Multiplayer")
            .document(widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}")
            .delete();
        _ref
            .collection("Multiplayer")
            .document(widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}")
            .collection("Ready")
            .document(widget._player1)
            .delete();
        _ref
            .collection("Multiplayer")
            .document(widget._player1.hashCode > widget._player2.hashCode
                ? "${widget._player1}${widget._player2}"
                : "${widget._player2}${widget._player1}")
            .collection("Ready")
            .document(widget._player2)
            .delete();
      }
    });
    super.dispose();
  }

  TextEditingController _myNumController = TextEditingController();

  double _height = 100.0;
  bool _showCircularProgressBar = false;
  bool _readyState = false;
  var _turn;
  bool _isWinnerDecided = false;

  String _player1NumState = "";
  String _player2NumState = "";

  _distributeCoins() {
    var _ref = Firestore.instance;
    _ref
        .collection("Users")
        .document(widget._player1)
        .collection("Points")
        .document("Points")
        .get()
        .then((onValue) {
      DatabaseProvider(uid: widget._player1).updateUserPoints(
        cash: onValue.data["cash"],
        coins: onValue.data["coins"] + widget._coins,
        gems: onValue.data["gems"],
      );
    });

    _ref
        .collection("Users")
        .document(widget._player2)
        .collection("Points")
        .document("Points")
        .get()
        .then((onValue) {
      DatabaseProvider(uid: widget._player2).updateUserPoints(
        cash: onValue.data["cash"],
        coins: onValue.data["coins"] - widget._coins,
        gems: onValue.data["gems"],
      );
    });

    _ref
        .collection("Users")
        .document(widget._player1)
        .collection("WonLost")
        .document("WonLost")
        .get()
        .then((onValue) {
      DatabaseProvider(uid: widget._player1).updateUserAchievements(
          gameWon: onValue.data["gameWon"] + 1,
          gameLost: onValue.data["gameLost"]);
    });

    _ref
        .collection("Users")
        .document(widget._player2)
        .collection("WonLost")
        .document("WonLost")
        .get()
        .then((onValue) {
      DatabaseProvider(uid: widget._player2).updateUserAchievements(
          gameWon: onValue.data["gameWon"],
          gameLost: onValue.data["gameLost"] + 1);
    });
  }

  Future<void> _showWinLoseDialog(String _state) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 30.0),
                    width: MediaQuery.of(context).size.width - 100,
                    height: MediaQuery.of(context).size.height - 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 100.0,
                          padding: const EdgeInsets.only(right: 30.0),
                          child: _numberSection(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    color: _state == "win"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: _state == "win"
                                            ? "Congratulations!!\n"
                                            : "I am sorry!!,\n"),
                                    TextSpan(
                                        text: _state == "win"
                                            ? "You won!"
                                            : "You lost!",
                                        style: TextStyle(fontSize: 20.0)),
                                  ])),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        // Container(
                        //   padding: const EdgeInsets.only(right: 20.0),
                        //   child: _myNumberState == "Correct"
                        //       ? widget._gameMod == "Online with cash"
                        //           ? RichText(
                        //               textAlign: TextAlign.center,
                        //               text: TextSpan(
                        //                   style: TextStyle(
                        //                     fontSize: 14,
                        //                     color: Colors.grey,
                        //                   ),
                        //                   children: [
                        //                     TextSpan(text: "(Your money "),
                        //                     TextSpan(
                        //                         text:
                        //                             "<Rs Rs ${widget._amount ~/ 1.5}> ",
                        //                         style: TextStyle(
                        //                             color: Color(0xff1C2826),
                        //                             fontWeight:
                        //                                 FontWeight.w700)),
                        //                     TextSpan(
                        //                         text:
                        //                             "will be transferred to your phone within 24 hours from now)")
                        //                   ]))
                        //           : RichText(
                        //               textAlign: TextAlign.center,
                        //               text: TextSpan(
                        //                   style: TextStyle(
                        //                     fontSize: 14,
                        //                     color: Colors.grey,
                        //                   ),
                        //                   children: [
                        //                     TextSpan(text: "(Your"),
                        //                     TextSpan(
                        //                         text:
                        //                             "${(widget._amount - 20 / 100 * widget._amount).toInt()}",
                        //                         style: TextStyle(
                        //                             color: Color(0xff1C2826),
                        //                             fontWeight:
                        //                                 FontWeight.w700)),
                        //                     TextSpan(
                        //                         text:
                        //                             "has been transferred to your account)")
                        //                   ]))
                        //       : Text(
                        //           "Better luck next time.",
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             color: Colors.grey,
                        //           ),
                        //         ),
                        // ),
                        SizedBox(
                          height: 50.0,
                        ),
                        StickyButton("Exit", "", () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  _isNumCorrect(final _multiplayer) async {
    if (int.parse(_myNumController.text) > widget._theNumber) {
      setState(() {
        _player1NumState = "Too high!";
      });
      Timer(Duration(seconds: 3), () {
        setState(() {
          _turn = widget._player2;
        });
        Multiplayer(
                uniqueId: widget._player1.hashCode > widget._player2.hashCode
                    ? "${widget._player1}${widget._player2}"
                    : "${widget._player2}${widget._player1}")
            .sendInfo(
                _turn, _player1NumState, "", widget._theNumber, widget._coins);
      });
    } else if (int.parse(_myNumController.text) < widget._theNumber) {
      setState(() {
        _player1NumState = "Too low!";
      });
      Timer(Duration(seconds: 3), () {
        setState(() {
          _turn = widget._player2;
        });
        Multiplayer(
                uniqueId: widget._player1.hashCode > widget._player2.hashCode
                    ? "${widget._player1}${widget._player2}"
                    : "${widget._player2}${widget._player1}")
            .sendInfo(
                _turn, _player1NumState, "", widget._theNumber, widget._coins);
      });
    } else if (int.parse(_myNumController.text) == widget._theNumber) {
      setState(() {
        _player1NumState = "Correct";
      });
      Timer(Duration(seconds: 3), () {
        _showWinLoseDialog("win");
        setState(() {
          _turn = widget._player2;
          _isWinnerDecided = true;
        });
        Multiplayer(
                uniqueId: widget._player1.hashCode > widget._player2.hashCode
                    ? "${widget._player1}${widget._player2}"
                    : "${widget._player2}${widget._player1}")
            .sendInfo(_turn, _player1NumState, widget._player1,
                widget._theNumber, widget._coins);
        _distributeCoins();

        Multiplayer().sendWinnerInfo(
            widget._player1, widget._coins, DateTime.now().toString());
            
        Multiplayer().sendLoserInfo(
            widget._player2, widget._coins, DateTime.now().toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: DatabaseProvider(uid: widget._player1).userDetail,
      child: SlidingUpPanel(
        maxHeight: 320.0,
        minHeight: 130.0,
        panel: _mySectionOpened(),
        collapsed: _mySectionClosed(),
        body: Container(
          color: Color(0xff1fa9cc),
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _opponentSection(),
                  Expanded(child: _numberSection()),
                  SizedBox(
                    height: _height,
                  ),
                ],
              ),
            ),
          ),
        ),
        onPanelOpened: () {
          setState(() {
            _height = 330.0;
          });
        },
        onPanelClosed: () {
          setState(() {
            _height = 100.0;
          });
        },
      ),
    );
  }

  Widget _mySectionClosed() {
    final _ready1 = Provider.of<ReadyModel1>(context);
    final _ready2 = Provider.of<ReadyModel2>(context);
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      color: Colors.white,
      child: _ready1 != null &&
              _ready2 != null &&
              _ready1.isOpponentReady &&
              _ready2.isOpponentReady
          ? Column(
              children: <Widget>[
                Icon(Icons.arrow_drop_up, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "Your number is: ",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xff1C2826),
                              fontWeight: FontWeight.w700),
                        ),
                        _showCircularProgressBar
                            ? Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : Text(
                                _player1NumState != null
                                    ? _player1NumState
                                    : "",
                                style: TextStyle(
                                    fontSize: 26.0,
                                    color: _player1NumState == "Correct"
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w700),
                              ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.exit_to_app, color: Colors.black),
                            onPressed: () {}),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(flex: 2, child: _numberInputSection()),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(child: _guessBtnSection()),
                  ],
                ),
              ],
            )
          : Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  _readyState ? "I am ready" : "I am not ready",
                  style: TextStyle(
                      fontSize: 24.0,
                      color: _readyState ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      color: !_readyState
                          ? Colors.green
                          : Colors.green.withOpacity(0.2),
                      onPressed: () {
                        setState(() {
                          _readyState = true;
                        });
                        Multiplayer(
                                uniqueId: widget._player1.hashCode >
                                        widget._player2.hashCode
                                    ? "${widget._player1}${widget._player2}"
                                    : "${widget._player2}${widget._player1}",
                                haha: widget._player2)
                            .sendReadyInfo(true);
                      },
                      child: Container(
                        child: Center(
                          child: Text(
                            "Ready",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    FlatButton(
                      color: _readyState
                          ? Colors.red
                          : Colors.red.withOpacity(0.2),
                      onPressed: () {
                        setState(() {
                          _readyState = false;
                        });
                        Multiplayer(
                                uniqueId: widget._player1.hashCode >
                                        widget._player2.hashCode
                                    ? "${widget._player1}${widget._player2}"
                                    : "${widget._player2}${widget._player1}",
                                haha: widget._player2)
                            .sendReadyInfo(false);
                      },
                      child: Container(
                        child: Center(
                          child: Text(
                            "Not ready",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }

  Widget _opponentSection() {
    final _multiplayer = Provider.of<MultiplayerModel>(context);
    final _ready = Provider.of<ReadyModel>(context);
    final _ready1 = Provider.of<ReadyModel1>(context);
    final _ready2 = Provider.of<ReadyModel2>(context);

    return StreamBuilder(
        stream: DatabaseProvider(uid: widget._player2).userDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0)),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      !_ready1.isOpponentReady || !_ready2.isOpponentReady
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text(
                                _ready == null
                                    ? "Not ready"
                                    : !_ready.isOpponentReady
                                        ? "Not ready"
                                        : "Ready",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color:
                                        _ready != null && _ready.isOpponentReady
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                _multiplayer.turn != widget._player1 &&
                                        _ready1.isOpponentReady &&
                                        _ready2.isOpponentReady &&
                                        !_isWinnerDecided
                                    ? Row(
                                        children: <Widget>[
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            "Guessing..",
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        _isWinnerDecided
                                            ? ""
                                            : _multiplayer.player2NumState,
                                        style: TextStyle(
                                            fontSize: 24.0,
                                            color:
                                                _multiplayer.player2NumState ==
                                                        "Correct"
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.w700),
                                      ),
                              ],
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipOval(
                            child: Container(
                              width: 50.0,
                              height: 50.0,
                              child: Image.asset(
                                  "images/avatars/${snapshot.data.profileImgNum}.png",
                                  fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${snapshot.data.userName}",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xff1C2826),
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 5.0),
                                _userPointSection("opponent"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget _userPointSection(var _result) {
    return StreamBuilder(
      stream: _result != "me"
          ? DatabaseProvider(uid: widget._player2).points
          : DatabaseProvider(uid: widget._player1).points,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
                color: Color(0xff493BAA),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      offset: Offset(0.0, 4.0),
                      blurRadius: 20.0)
                ]),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "Coins",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SvgPicture.asset("images/coins.svg"),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      snapshot.data.coins.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Gems",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SvgPicture.asset("images/gems.svg"),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      snapshot.data.gems.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Cash",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SvgPicture.asset("images/cash.svg"),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      "${snapshot.data.cash}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _numberSection() {
    return Stack(
      children: <Widget>[
        Center(
          child: Stack(
            children: <Widget>[
              SvgPicture.asset("images/game_page_main.svg"),
              Positioned.fill(
                child: Center(
                  child: Text(
                    _player1NumState == "Correct" ||
                            _player2NumState == "Correct"
                        ? "${widget._theNumber}"
                        : "####",
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        _height == 100
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AdmobBanner(
                    adUnitId: "ca-app-pub-4056821571384483/8381836879",
                    adSize: AdmobBannerSize.BANNER,
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget _mySectionOpened() {
    final _user = Provider.of<User>(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Your number is: ",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xff1C2826),
                          fontWeight: FontWeight.w700),
                    ),
                    _showCircularProgressBar
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Text(
                            _player1NumState != null ? _player1NumState : "",
                            style: TextStyle(
                                fontSize: 26.0,
                                color: _player1NumState == "Correct"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w700),
                          ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _numberInputSection(),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: _guessBtnSection()),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    child: Image.asset(
                        "images/avatars/${_user.profileImgNum}.png",
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _user.userName,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xff1C2826),
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 5.0),
                      _userPointSection("me"),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _guessBtnSection() {
    final _multiplayer = Provider.of<MultiplayerModel>(context);
    return FlatButton(
      onPressed: () {
        if (_multiplayer.turn == widget._player1) {
          if (_myNumController.text != "") {
            _isNumCorrect(_multiplayer);
            setState(() {
              _showCircularProgressBar = true;
            });
            Timer(Duration(seconds: 3), () {
              setState(() {
                _showCircularProgressBar = false;
              });
            });
          }
        }
      },
      color: Color(0xff6C63FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      child: Container(
        height: 20.0,
        child: Center(
          child: Text(
            "Guess",
            style: TextStyle(color: Colors.white, fontSize: 12.0),
          ),
        ),
      ),
    );
  }

  Widget _numberInputSection() {
    final _multiplayer = Provider.of<MultiplayerModel>(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: TextFormField(
        enabled:
            _multiplayer.turn == widget._player1 && _multiplayer.winner == ""
                ? true
                : false,
        onTap: () {},
        keyboardType: TextInputType.number,
        controller: _myNumController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            border: InputBorder.none,
            hintText: "Number"),
      ),
    );
  }
}
