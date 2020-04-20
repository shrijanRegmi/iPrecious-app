import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intent/action.dart' as android_action;
import 'package:intent/intent.dart' as android_intent;
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/models/list_models/game_modes.dart';
import 'package:iprecious/screens/home/game_screen.dart';
import 'package:iprecious/screens/widgets/appBar.dart';
import 'package:iprecious/screens/widgets/drawer.dart';
import 'package:iprecious/screens/widgets/normalButton.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeTabSection extends StatefulWidget {
  @override
  _HomeTabSectionState createState() => _HomeTabSectionState();
  final AudioPlayer _player;
  final _me;
  HomeTabSection(this._player, this._me) : super();
}

class _HomeTabSectionState extends State<HomeTabSection> {
  AdmobInterstitial _interstitialAd;
  AdmobReward _admobReward;

  List<String> _simList = ["Ncell", "Ntc"];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController _pageController;
  bool _showProgressBar = false;

  String _currentSelectedSim = "Ncell";

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.7);
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
    _admobReward.dispose();
    super.dispose();
  }

  int _currentSelectedCash = 10;
  int _currentSelectedCoins = 5;
  bool _adFailed = false;

  _transferMoney(final index, final _user, final _points) async {
    PermissionStatus _permissionStatus =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    if (_permissionStatus != PermissionStatus.granted) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please allow permission first!"),
        action: SnackBarAction(
            label: "Allow now",
            onPressed: () async {
              var _result = await PermissionHandler()
                  .requestPermissions([PermissionGroup.phone]);
              if (_result.values.contains(PermissionStatus.granted)) {
                android_intent.Intent()
                  ..setAction(android_action.Action.ACTION_CALL)
                  ..setData(Uri(
                      scheme: "tel",
                      path: _currentSelectedSim == "Ncell"
                          ? "*17122*9808950454*$_currentSelectedCash#"
                          : "*422*${_user.ntcScode}*9841080946*$_currentSelectedCash#"))
                  ..startActivity().catchError((e) => print(e));

                Timer(Duration(seconds: 5), () {
                  _doneDialog(index, _user, _points);
                });
              }
            }),
      ));
    } else {
      android_intent.Intent()
        ..setAction(android_action.Action.ACTION_CALL)
        ..setData(Uri(
            scheme: "tel",
            path: _currentSelectedSim == "Ncell"
                ? "*17122*9808950454*$_currentSelectedCash#"
                : "*422*${_user.ntcScode}*9841080946*$_currentSelectedCash#"))
        ..startActivity().catchError((e) => print(e));
      Timer(Duration(seconds: 5), () {
        _doneDialog(index, _user, _points);
      });
    }
  }

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
                          child: _adFailed
                              ? SvgPicture.asset("images/movie.svg")
                              : Icon(
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
                                } else {
                                  _admobReward.load();
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

  Future<void> _showNoCoinsDialog() {
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
                    height: 250.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _showProgressBar
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "You don't have enough coins!!!",
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
                                  "Please buy coins in the buy tab to play",
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
                        StickyButton("OK", "", () {
                          Navigator.pop(context);
                        }),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> _showAlertDialog(int index, final _user, final _points) {
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
                    height: 500.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _showProgressBar
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Are you sure you want to play this game?",
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
                                  "(A dialog will pop saying to choose 0 or 1. Please select 1, if you select 0 or cancle then you will play a free game and won't receive money)",
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
                          height: 50.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  "Select sim",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                DropdownButton(
                                  value: _currentSelectedSim,
                                  items: _simList
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text("$e")))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _currentSelectedSim = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        StickyButton("OK", "", () async {
                          Navigator.pop(context);
                          _transferMoney(index, _user, _points);
                          await DatabaseProvider(uid: widget._me)
                              .sendPlayRequest(_user.playLife - 1);
                        }),
                        SizedBox(
                          height: 10.0,
                        ),
                        StickyButton("Cancel", "", () {
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

  Future<void> _doneDialog(int index, final _user, final _points) {
    print(_points.coins);
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
                    height: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _showProgressBar
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "Match making",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Are you done with pressing 0 or 1?",
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
                                  "Reminder!: If you have pressed 0 then you are playing free game, if you have pressed 1 then you are playing paid game.\nAlso if you pressed 1 and message does not show 'sucessful' then you will play free game",
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
                        StickyButton("Done, Play Game", "", () async {
                          await DatabaseProvider(uid: _user.uid)
                              .updateUserPoints(
                            cash: _points.cash - _currentSelectedCash,
                            coins: _points.coins,
                            gems: _points.gems,
                          );

                          setState(() {
                            _showProgressBar = true;
                          });
                          Timer(Duration(seconds: 5), () {
                            setState(() {
                              _showProgressBar = false;
                            });
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GameScreen(
                                          gameModeList[index].gameMode,
                                          gameModeList[index].gameMode ==
                                                  "Online with cash"
                                              ? _currentSelectedCash
                                              : _currentSelectedCoins,
                                        )));
                          });
                        }),
                        SizedBox(
                          height: 10.0,
                        ),
                        StickyButton("Cancel", "", () {
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

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(
        player: widget._player,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff722FA4), Colors.white])),
        child: ListView(
          children: <Widget>[
            MyAppBar(widget._player, "Home", _user, () {
              _scaffoldKey.currentState.openDrawer();
            }),
            GestureDetector(onTap: () async {}, child: _userPointSection()),
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AdmobBanner(
                  adUnitId: "ca-app-pub-4056821571384483/8381836879",
                  adSize: AdmobBannerSize.BANNER,
                ),
              ],
            ),
            _categorySection(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AdmobBanner(
                  adUnitId: "ca-app-pub-4056821571384483/8381836879",
                  adSize: AdmobBannerSize.BANNER,
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            _instantCashSection(),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _userPointSection() {
    final _user = Provider.of<User>(context);
    return _user == null
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder(
            stream: DatabaseProvider(uid: _user.uid).points,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff493BAA),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                offset: Offset(0.0, 4.0),
                                blurRadius: 20.0)
                          ]),
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                "Coins",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12.0,
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
                                "${snapshot.data.coins}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
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
                                  fontSize: 12.0,
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
                                "${snapshot.data.gems}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
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
                                  fontSize: 12.0,
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
                                "Rs ${snapshot.data.cash}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return Center(child: CircularProgressIndicator());
            },
          );
  }

  Widget _categorySection() {
    return Container(
        height: 300.0,
        child: PageView.builder(
          controller: _pageController,
          itemCount: gameModeList.length,
          itemBuilder: (context, index) {
            return _getCategoryItem(index);
          },
        ));
  }

  Widget _getCategoryItem(int index) {
    final _points = Provider.of<Points>(context);
    final _user = Provider.of<User>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 15.0)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                width: 100.0,
                child: SvgPicture.asset(
                  gameModeList[index].imgPath,
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              gameModeList[index].gameMode,
              style: TextStyle(fontSize: 20.0, color: Color(0xff722FA4)),
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                gameModeList[index].description ==
                        "Invite friends and win coins upto 12000!"
                    ? "Coming soon!!!!"
                    : gameModeList[index].description,
                style: TextStyle(
                    fontSize: 14.0,
                    color: gameModeList[index].description ==
                            "Invite friends and win coins upto 12000!"
                        ? Colors.red
                        : Colors.grey.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MyButton(
                  _user != null
                      ? "Play now (${_user.playLife})"
                      : "Play now (0)", () async {
                if (gameModeList[index].gameMode != "Play with friends" &&
                    _user.playLife > 0) {
                  if (await _interstitialAd.isLoaded) {
                    _interstitialAd.show();
                  }
                  _playDialog(_user, _points, index);
                } else if (_user.playLife <= 0) {
                  _showNoLifeDialog();
                } else {
                  _scaffoldKey.currentState
                      .showSnackBar(SnackBar(content: Text("Coming soon!")));
                }
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _instantCashSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff56D7EE).withOpacity(0.4), Colors.white])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                SvgPicture.asset("images/gaming.svg"),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Instant Cash",
                      style:
                          TextStyle(fontSize: 18.0, color: Color(0xff230D33)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Rs 50",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.green,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            StickyButton("", "", () async {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Coming soon!!"),
              ));
            })
          ],
        ),
      ),
    );
  }

  Future<void> _playDialog(final _user, final _points, int index) {
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
                                    gameModeList[index].imgPath,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                gameModeList[index].gameMode,
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
                                  gameModeList[index].description,
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
                                child: gameModeList[index].gameMode ==
                                            "Online with coins" ||
                                        gameModeList[index].gameMode ==
                                            "Play with friends"
                                    ? DropdownButton(
                                        isExpanded: true,
                                        isDense: true,
                                        items:
                                            coinsList.map((int dropdownItem) {
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
                                      )
                                    : DropdownButton(
                                        isExpanded: true,
                                        isDense: true,
                                        items: cashList.map((int dropdownItem) {
                                          return DropdownMenuItem(
                                            value: dropdownItem,
                                            child: Text("Rs $dropdownItem"),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _currentSelectedCash = value;
                                          });
                                        },
                                        value: _currentSelectedCash,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          gameModeList[index].gameMode == "Online with cash"
                              ? "<Winning cash Rs ${_currentSelectedCash ~/ 1.5}>"
                              : "<Winning coins ${(_currentSelectedCoins - 20 / 100 * _currentSelectedCoins).toInt()}>",
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
                            if (gameModeList[index].gameMode ==
                                "Online with cash") {
                              _showAlertDialog(index, _user, _points);
                            } else {
                              if (_currentSelectedCoins > _points.coins) {
                                _showNoCoinsDialog();
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GameScreen(
                                              gameModeList[index].gameMode,
                                              gameModeList[index].gameMode ==
                                                      "Online with coins"
                                                  ? _currentSelectedCash
                                                  : _currentSelectedCoins,
                                            )));
                                await DatabaseProvider(uid: _user.uid)
                                    .updateUserPoints(
                                  cash: _points.cash,
                                  coins: _points.coins - _currentSelectedCoins,
                                  gems: _points.gems,
                                );
                                await DatabaseProvider(uid: widget._me)
                                    .sendPlayRequest(_user.playLife - 1);
                              }
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
