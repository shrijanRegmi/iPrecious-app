import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/screens/widgets/appBar.dart';
import 'package:iprecious/screens/widgets/drawer.dart';
import 'package:iprecious/screens/widgets/normalButton.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:provider/provider.dart';

class ActivityTabSection extends StatefulWidget {
  @override
  _ActivityTabSectionState createState() => _ActivityTabSectionState();
  final _me;
  final AudioPlayer _player;
  ActivityTabSection(this._player, this._me);
}

class _ActivityTabSectionState extends State<ActivityTabSection> {
  AdmobInterstitial _interstitialAd;
  AdmobReward _admobReward;

  @override
  void initState() {
    super.initState();
    _interstitialAd = AdmobInterstitial(
        adUnitId: "ca-app-pub-4056821571384483/9120203477",
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.closed) {
            _interstitialAd.load();
          }
        });
    _admobReward = AdmobReward(
        adUnitId: "ca-app-pub-4056821571384483/8995547566",
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          var _ref = Firestore.instance;
          switch (event) {
            case AdmobAdEvent.closed:
              _admobReward.load();
              break;
            case AdmobAdEvent.loaded:
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
    super.dispose();
  }

  bool _isGiftOpening = false;
  bool _isGiftOpened = false;
  int _giftNum = 0;
  int _myGift = 0;
  bool _adFailed = false;

  _showDialog(var _result, User _user) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StreamProvider<Points>.value(
            value: DatabaseProvider(uid: _user.uid).points,
            child: StatefulBuilder(builder: (context, setState) {
              final _points = Provider.of<Points>(
                context,
              );
              return Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Container(
                      padding: const EdgeInsets.all(20.0),
                      height: 240.0,
                      width: MediaQuery.of(context).size.width - 100.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: _result == "Gift box"
                          ? Container(
                              child: !_isGiftOpened && _isGiftOpening
                                  ? Center(
                                      child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text("Opening gift",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                            )),
                                      ],
                                    ))
                                  : _isGiftOpened
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text("You got: ",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.0,
                                                  )),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                      "images/coins.svg"),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text("$_myGift coins",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      )),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              MyButton("Again", () {
                                                final _points =
                                                    Provider.of<Points>(context,
                                                        listen: false);
                                                DatabaseProvider(uid: _user.uid)
                                                    .updateUserPoints(
                                                  coins: _points.coins - 100,
                                                  cash: _points.cash,
                                                  gems: _points.gems,
                                                );
                                                var _rand = Random();
                                                setState(() {
                                                  _isGiftOpened = false;
                                                  _isGiftOpening = true;
                                                  _giftNum = _rand.nextInt(100);
                                                  if (_giftNum.isEven) {
                                                    _myGift = 2;
                                                  } else if (_giftNum > 80) {
                                                    _myGift = 100;
                                                  } else if (_giftNum > 70 &&
                                                      _giftNum < 80) {
                                                    _myGift = 50;
                                                  } else if (_giftNum == 9) {
                                                    _myGift = 1000;
                                                  } else {
                                                    _myGift = 0;
                                                  }
                                                });
                                                Timer(Duration(seconds: 3), () {
                                                  setState(() {
                                                    _isGiftOpened = true;
                                                  });
                                                });
                                                DatabaseProvider(uid: _user.uid)
                                                    .updateUserPoints(
                                                  coins: _points.coins -
                                                      100 +
                                                      _myGift,
                                                  cash: _points.cash,
                                                  gems: _points.gems,
                                                );
                                              }),
                                            ],
                                          ),
                                        )
                                      : Center(
                                          child:
                                              MyButton("Open gift", () async {
                                          DatabaseProvider(uid: _user.uid)
                                              .updateUserPoints(
                                            coins: _points.coins - 100,
                                            cash: _points.cash,
                                            gems: _points.gems,
                                          );
                                          var _rand = Random();
                                          setState(() {
                                            _isGiftOpening = true;
                                            _giftNum = _rand.nextInt(100);
                                            if (_giftNum.isEven) {
                                              _myGift = 2;
                                            } else if (_giftNum > 80) {
                                              _myGift = 100;
                                            } else if (_giftNum > 70 &&
                                                _giftNum < 80) {
                                              _myGift = 50;
                                            } else if (_giftNum == 9) {
                                              _myGift = 1000;
                                            } else {
                                              _myGift = 0;
                                            }
                                          });
                                          Timer(Duration(seconds: 3), () {
                                            setState(() {
                                              _isGiftOpened = true;
                                            });
                                          });
                                          DatabaseProvider(uid: _user.uid)
                                              .updateUserPoints(
                                            coins:
                                                _points.coins - 100 + _myGift,
                                            cash: _points.cash,
                                            gems: _points.gems,
                                          );
                                        })),
                            )
                          : _result == "Videos"
                              ? Container(
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        SvgPicture.asset("images/movie.svg"),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          _adFailed
                                              ? "Sorry! no videos are available currently"
                                              : "Watch videos to earn 2 free play life",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        _adFailed
                                            ? MyButton("OK", () async {
                                                Navigator.pop(context);
                                                if (await _admobReward
                                                    .isLoaded) {
                                                  setState(() {
                                                    _adFailed = false;
                                                  });
                                                } else {
                                                  _admobReward.load();
                                                }
                                              })
                                            : MyButton("Watch Now", () async {
                                                if (await _admobReward
                                                    .isLoaded) {
                                                  Navigator.pop(context);
                                                  _admobReward.show();
                                                  _adFailed = false;
                                                } else {
                                                  setState(() {
                                                    _adFailed = true;
                                                  });
                                                }
                                              })
                                      ],
                                    ),
                                  ),
                                )
                              : Container()),
                ),
              );
            }),
          );
        });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffFFA7A7), Colors.white])),
        child: Column(
          children: <Widget>[
            MyAppBar(widget._player, "Activities", _user, () {
              _scaffoldKey.currentState.openDrawer();
            }),
            Expanded(
              child: Stack(
                children: <Widget>[
                  _myActivitiesSection(),
                  Positioned(
                    bottom: 0.0,
                    child: Center(
                      child: AdmobBanner(
                        adUnitId: "ca-app-pub-4056821571384483/8381836879",
                        adSize: AdmobBannerSize.FULL_BANNER,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myActivitiesSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 3 / 4),
        children: <Widget>[
          _myActivitiesItem(
              "images/gift.svg", "images/coins.svg", "Gift box", "100"),
          _myActivitiesItem("images/movie.svg", "", "Videos", "Watch"),
          _myActivitiesItem(
              "images/refer.svg", "images/coins.svg", "Refer friend", "300"),
          _myActivitiesItem(
              "images/bet.svg", "images/time.svg", "Roulette", "03:55"),
          SizedBox(),
        ],
      ),
    );
  }

  Widget _myActivitiesItem(
      String _imgPath1, String _imgPath2, String _text1, String _text2) {
    final _user = Provider.of<User>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 15.0)
            ]),
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SvgPicture.asset(_imgPath1),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _text1,
                    style: TextStyle(fontSize: 18.0, color: Color(0xff722FA4)),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 20.0,
                right: 0.0,
                child: StickyButton(_text2, _imgPath2, () async {
                  if (_text1 != "Videos") {
                    if (await _interstitialAd.isLoaded) {
                      _interstitialAd.show();
                    }
                  }
                  if (_text1 == "Gift box") {
                    return _showDialog("Gift box", _user);
                  } else if (_text1 == "Videos") {
                    return _showDialog("Videos", _user);
                  }
                  // _scaffoldKey.currentState
                  //     .showSnackBar(SnackBar(content: Text("Coming soon!!")));
                }))
          ],
        ),
      ),
    );
  }
}
